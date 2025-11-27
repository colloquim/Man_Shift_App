// screens/micro_lessons_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import 'lesson_details_screen.dart';

class MicroLessonsScreen extends StatefulWidget {
  final List<Lesson> lessons;

  const MicroLessonsScreen({super.key, required this.lessons});

  @override
  State<MicroLessonsScreen> createState() => _MicroLessonsScreenState();
}

class _MicroLessonsScreenState extends State<MicroLessonsScreen> {
  late SharedPreferences _prefs;

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    _loadLessonProgress();
  }

  Future<void> _loadLessonProgress() async {
    _prefs = await SharedPreferences.getInstance();
    for (var lesson in widget.lessons) {
      final key = _lessonKey(lesson);
      final jsonStr = _prefs.getString(key);
      if (jsonStr != null) {
        try {
          final map = json.decode(jsonStr);
          lesson.completed = map['completed'] ?? false;
          lesson.reflection = map['reflection'];
        } catch (_) {}
      }
    }
    setState(() {});
  }

  String _lessonKey(Lesson lesson) => 'lesson:${lesson.title}';

  Future<void> _toggleLesson(Lesson lesson) async {
    setState(() => lesson.completed = !lesson.completed);
    await _prefs.setString(_lessonKey(lesson), json.encode(lesson.toJson()));
  }

  Future<void> _markAllDone() async {
    setState(() {
      for (var lesson in widget.lessons) {
        lesson.completed = true;
      }
    });
    for (var lesson in widget.lessons) {
      await _prefs.setString(_lessonKey(lesson), json.encode(lesson.toJson()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro Lessons'),
        backgroundColor: const Color(0xFF00A8A8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _markAllDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8A8),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Mark All Lessons Done",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = widget.lessons[index];
                  final dayName = weekDays[lesson.dayIndex % 7];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.menu_book,
                              color: lesson.completed
                                  ? Colors.green
                                  : Colors.black,
                              size: 32,
                            ),
                            title: Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                decoration: lesson.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              dayName,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                lesson.completed
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: lesson.completed
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => _toggleLesson(lesson),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LessonDetailScreen(lesson: lesson),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tip: ${lesson.actionableTip}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Reflect: ${lesson.reflectionPrompt}",
                            style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
