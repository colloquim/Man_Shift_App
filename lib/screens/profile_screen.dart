// screens/profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../models/user_badge.dart';
import '../services/firebase_service.dart'; // <-- import FirebaseService

class ProfileScreen extends StatefulWidget {
  final List<Lesson> lessons;
  const ProfileScreen({super.key, required this.lessons});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < widget.lessons.length; i++) {
      final key = _lessonKey(widget.lessons[i]);
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        try {
          final Map<String, dynamic> map = json.decode(jsonStr);
          widget.lessons[i].completed = map['completed'] ?? false;
          widget.lessons[i].reflection = map['reflection'];
        } catch (_) {}
      }
    }
    setState(() {});
  }

  String _lessonKey(Lesson l) => 'lesson:${l.title}';

  Future<void> _saveLesson(Lesson lesson) async {
    await prefs.setString(_lessonKey(lesson), json.encode(lesson.toJson()));
    setState(() {});

    // Log event safely
    FirebaseService.instance.logEvent(
      'lesson_updated',
      parameters: {
        'title': lesson.title,
        'completed': lesson.completed ? 1 : 0,
        'has_reflection': (lesson.reflection?.isNotEmpty ?? false) ? 1 : 0,
      },
    );
  }

  List<UserBadge> _computeBadges() {
    final List<UserBadge> badges = [];
    final completedCount = widget.lessons.where((l) => l.completed).length;
    final reflectionCount =
        widget.lessons.where((l) => (l.reflection?.isNotEmpty ?? false)).length;

    if (completedCount >= 3) {
      badges.add(UserBadge(
        id: "3-day",
        title: "3-Lesson Completed",
        description: "Completed 3 lessons.",
        icon: "🔥",
      ));
    }

    if (completedCount == widget.lessons.length) {
      badges.add(UserBadge(
        id: "full-week",
        title: "All Lessons Done",
        description: "Completed every lesson.",
        icon: "🏆",
      ));
    }

    if (reflectionCount >= 5) {
      badges.add(UserBadge(
        id: "reflect-5",
        title: "Reflective 5",
        description: "Submitted 5 reflection logs.",
        icon: "⭐",
      ));
    }

    // Log badge count
    FirebaseService.instance.logEvent(
      'badges_updated',
      parameters: {'badge_count': badges.length},
    );

    return badges;
  }

  void _editReflection(BuildContext context, Lesson lesson) {
    final controller = TextEditingController(text: lesson.reflection ?? "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reflection — ${lesson.title}"),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: "Write your reflection here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8A8)),
            onPressed: () {
              setState(() {
                lesson.reflection = controller.text.trim();
                lesson.completed = true; // reflection implies lesson done
              });
              _saveLesson(lesson);

              // Log reflection saved
              FirebaseService.instance.logEvent(
                'reflection_saved',
                parameters: {'title': lesson.title},
              );

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.lessons.where((l) => l.completed).length;
    final progress = widget.lessons.isNotEmpty
        ? (completedCount / widget.lessons.length)
        : 0.0;
    final badges = _computeBadges();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Progress"),
        backgroundColor: const Color(0xFF00A8A8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          Text("Lessons Completed: $completedCount/${widget.lessons.length}",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 12,
                color: const Color(0xFF00A8A8),
                backgroundColor: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text("Badges (${badges.length})",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          if (badges.isEmpty)
            const Text(
                "Earn badges by completing lessons and writing reflections.",
                style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: badges.map((b) {
                return Chip(
                  avatar: Text(b.icon, style: const TextStyle(fontSize: 18)),
                  backgroundColor: Colors.teal.shade100,
                  label: Text(b.title),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          const Text("Reflection Logs", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Column(
            children: widget.lessons.map((lesson) {
              if (!lesson.completed) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(lesson.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(lesson.reflection?.isNotEmpty == true
                      ? lesson.reflection!
                      : lesson.reflectionPrompt),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editReflection(context, lesson)),
                  onTap: () => _editReflection(context, lesson),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text("All Lessons", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Column(
            children: widget.lessons.map((lesson) {
              return SwitchListTile(
                title: Text(lesson.title),
                subtitle: Text(lesson.reflectionPrompt),
                value: lesson.completed,
                onChanged: (val) {
                  setState(() {
                    lesson.completed = val;
                    if (!val) lesson.reflection = null;
                  });
                  _saveLesson(lesson);

                  FirebaseService.instance.logEvent(
                    'lesson_toggled',
                    parameters: {
                      'title': lesson.title,
                      'completed': val ? 1 : 0
                    },
                  );
                },
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
