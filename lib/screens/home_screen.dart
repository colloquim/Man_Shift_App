// screens/home_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../models/lesson.dart';
import '../services/firebase_service.dart';
import 'profile_screen.dart';
import 'micro_lessons_screen.dart';
import 'chat_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late SharedPreferences _prefs;
  bool _loaded = false;
  bool _firebaseReady = false;

  List<bool> streak = List.filled(7, false);
  final List<String> days = ["M", "T", "W", "Th", "F", "S", "Su"];
  bool _isDarkMode = false;

  late ConfettiController _confettiController;

  final List<Lesson> lessons = [
    Lesson(
      title: "Respect Boundaries Online",
      description:
          "As a man, you must learn to respect consent and privacy in every digital space, recognizing that the internet is not an open license to share others' information or likeness. This means understanding that personal information, photos, or even a casual private conversation belongs to the person who shared it, and you do not have the right to broadcast it. Your respect for physical boundaries must extend seamlessly into the digital realm.",
      actionableTip:
          "Ask for explicit permission before sharing someone's content, private message screenshots, or tagging them in a photo. Treat a person’s digital profile like their private property; never assume access or agreement.",
      reflectionPrompt:
          "Did I respect others’ digital boundaries today? (Did I share anything without permission, or did I stop myself from tagging someone who might not want visibility?)",
      dayIndex: 0,
    ),
    Lesson(
      title: "Recognize Cyber Harassment",
      description:
          "To protect women and ensure online safety, as a man, you must develop the skill to identify and call out cyber harassment. This includes abusive comments, stalking, doxing (sharing private information), and any sustained malicious or aggressive communication. You must recognize that what you might dismiss as a 'heated debate' can feel like a direct threat to a woman.",
      actionableTip:
          "When you encounter harmful content—especially targeted harassment, threats, or explicit misogyny—you must immediately report it to the platform and block the sender. Do not engage in a debate with the harasser; prioritize disrupting the abuse and signaling that such behavior is unacceptable in your digital space.",
      reflectionPrompt:
          "Did I respond appropriately to online harassment today? (Did I report an abusive comment, or did I scroll past something harmful?)",
      dayIndex: 1,
    ),
    Lesson(
      title: "Challenge Harmful Digital Stereotypes",
      description:
          "As a man committed to respect, you must actively reject and disrupt the spread of sexist memes, jokes, and harmful digital narratives that rely on outdated or damaging stereotypes about women. Misogynistic 'humor' is not harmless; it creates a culture that normalizes disrespect and fuels real-world violence.",
      actionableTip:
          "Call out or, at minimum, actively refuse to share or 'like' any content that demeans women. Use the Interruption Technique by commenting briefly, 'Not cool,' or 'This joke is misogynistic,' or privately messaging the person who posted it. Your silence is complicity in spreading the harmful content.",
      reflectionPrompt:
          "What stereotype did I challenge online today? (Did I refuse to laugh at a sexist joke, or did I call out a comment that reduced a woman to her appearance?)",
      dayIndex: 2,
    ),
    Lesson(
      title: "Practice Digital Empathy",
      description:
          "To ensure your online interactions are safe and respectful, you must practice digital empathy: the ability to recognize the emotional weight and context behind a message before responding. Recognize that women often post or engage from a position of needing to manage potential online aggression, which should temper your own reactions.",
      actionableTip:
          "When you read a message, especially one that sparks an immediate, strong reaction, you should pause for five minutes before replying. During this pause, deliberately consider the other person's perspective and potential emotional state. Ask yourself: 'How could this message be interpreted if I were coming from a less privileged position?'",
      reflectionPrompt:
          "How did I practice empathy online today? (Did I prioritize understanding over arguing, or did I choose not to engage in a reply that would have escalated tension?)",
      dayIndex: 3,
    ),
    Lesson(
      title: "Promote Positive Digital Spaces",
      description:
          "As a man, you have a duty to not just avoid being toxic, but to actively promote and cultivate constructive conversations and safe online communities. This shifts your role from passive user to active builder of respectful digital culture, which is vital for the well-being of women and marginalized users.",
      actionableTip:
          "Share resources, uplifting messages, or actively support peers online who are championing respect and equality. When a healthy conversation is occurring, contribute constructively to sustain it, thereby crowding out negativity and reinforcing positive community standards.",
      reflectionPrompt:
          "How did I contribute positively online today? (Did I share an article that promotes gender equality, or did I offer support to a woman being unfairly criticized?)",
      dayIndex: 4,
    ),
    Lesson(
      title: "Accountability & Consent",
      description:
          "Accountability is the cornerstone of respect. As a man, you must take full responsibility for your mistakes and ensure your interactions are governed by digital consent. This means owning up immediately when your words or actions cause harm online, regardless of your intention.",
      actionableTip:
          "If you realize you have overstepped a boundary, made a thoughtless comment, or violated someone's privacy online, you must issue a specific, unconditional apology immediately. The apology should focus on the impact ('I apologize for making you feel unsafe when I shared that') and not include any justification ('...but I didn't mean to').",
      reflectionPrompt:
          "What online action did I take responsibility for today? (Did I apologize for interrupting someone, or did I correct misinformation I spread?)",
      dayIndex: 5,
    ),
    Lesson(
      title: "Weekly Reflection & Digital Detox",
      description:
          "To ensure sustained growth, as a man, you must commit to a structured, periodic review of your online behavior. This weekly reflection allows you to identify toxic patterns, reduce harmful engagement, and solidify positive digital habits that protect and respect women.",
      actionableTip:
          "Dedicate a specific time each week to step away from your devices and reflect on the past seven days' interactions. Use this time offline to plan specific improvements, such as blocking three toxic accounts, researching a new perspective on consent, or committing to two days without aggressive online commentary.",
      reflectionPrompt:
          "What did I learn about my online behavior this week? (What pattern do I need to break, and what new, respectful habit will I commit to next week?)",
      dayIndex: 6,
    ),
  ];

  int get completedDays => streak.where((s) => s).length;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _loadSavedProgress();

    FirebaseService.instance.initialize().then((_) {
      setState(() {
        _firebaseReady = true;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProgress() async {
    _prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < lessons.length; i++) {
      final key = _lessonKey(lessons[i]);
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          final map = json.decode(jsonString);
          lessons[i].completed = map['completed'] ?? false;
          lessons[i].reflection = map['reflection'];
          streak[lessons[i].dayIndex] = lessons[i].completed;
        } catch (e) {
          debugPrint('Error loading lesson progress: $e');
        }
      }
    }

    final savedStreak = _prefs.getStringList('streak_days');
    if (savedStreak != null && savedStreak.length == 7) {
      streak = savedStreak.map((s) => s == '1').toList();
    }

    _isDarkMode = _prefs.getBool('dark_mode') ?? false;
    setState(() => _loaded = true);
  }

  String _lessonKey(Lesson lesson) => 'lesson:${lesson.title}';

  Future<void> _saveLesson(Lesson lesson) async {
    await _prefs.setString(_lessonKey(lesson), json.encode(lesson.toJson()));
  }

  Future<void> _toggleDay(int index) async {
    setState(() {
      streak[index] = !streak[index];
      lessons[index].completed = streak[index];
      _saveLesson(lessons[index]);

      if (streak[index]) _confettiController.play();

      if (_firebaseReady) {
        FirebaseService.instance.logEvent(
          'streak_toggled',
          parameters: {'day_index': index, 'completed': streak[index] ? 1 : 0},
        );
      }
    });

    await _prefs.setStringList(
        'streak_days', streak.map((b) => b ? '1' : '0').toList());
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => _isDarkMode = value);
    await _prefs.setBool('dark_mode', value);

    if (_firebaseReady) {
      FirebaseService.instance.logEvent(
        'theme_changed',
        parameters: {'dark_mode': value ? 1 : 0},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const ChatScreen(),
      ProfileScreen(lessons: lessons),
    ];

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bgColor = _isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(
                  color: _isDarkMode ? Colors.white : Colors.black),
              title: Text(
                "MANSHIFT",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            )
          : null,
      drawer: _currentIndex == 0 ? _buildDrawer() : null,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor: const Color(0xFF00A8A8),
        unselectedItemColor: _isDarkMode ? Colors.white70 : Colors.grey[600],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // ------------------------ HOME TAB ------------------------
  Widget _buildHomeTab() {
    final cardColor = _isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = _isDarkMode ? Colors.white70 : Colors.grey[700];

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------- DAILY LESSONS CARD -----------
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DAILY LESSONS",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: textColor)),
                        const SizedBox(height: 8),
                        Text("Challenging Toxic Masculinity",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 8),
                        Text(
                          "Understand the impact of toxic masculinity, especially in digital spaces, and the importance of challenging it.",
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: ElevatedButton(
                            onPressed: _firebaseReady
                                ? () {
                                    FirebaseService.instance.logEvent(
                                      'lesson_started',
                                      parameters: {'count': 1},
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => MicroLessonsScreen(
                                              lessons: lessons)),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A8A8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Start",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ----------- STREAK CARD -----------
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Streak",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 8),
                        Text(
                          completedDays == 0
                              ? "No days completed yet"
                              : completedDays == 1
                                  ? "1 day completed"
                                  : "$completedDays days completed",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: subTextColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (index) {
                            return GestureDetector(
                              onTap: () => _toggleDay(index),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: streak[index]
                                      ? const Color(0xFF00A8A8)
                                      : Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: streak[index]
                                        ? Colors.white
                                        : (_isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 20,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.pink,
              Colors.orange
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------ DRAWER ------------------------
  Drawer _buildDrawer() {
    final drawerBg = _isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF00A8A8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_filled, size: 60, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text("MANSHIFT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("v1.0.0",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: textColor),
              title: Text("Profile", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book, color: textColor),
              title: Text("Daily Lessons", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MicroLessonsScreen(lessons: lessons)));
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: textColor),
              title: Text("Your Streak", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: Icon(Icons.note, color: textColor),
              title: Text("Reflections", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            const Divider(color: Colors.grey),
            Theme(
              data: ThemeData(
                textTheme: TextTheme(bodyMedium: TextStyle(color: textColor)),
              ),
              child: ExpansionTile(
                leading: Icon(Icons.settings, color: textColor),
                title: Text("Settings", style: TextStyle(color: textColor)),
                children: [
                  SwitchListTile(
                    title: Text(_isDarkMode ? "Dark Mode" : "Light Mode",
                        style: TextStyle(color: textColor)),
                    value: _isDarkMode,
                    activeColor: const Color(0xFF00A8A8),
                    onChanged: _toggleTheme,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.info, color: textColor),
              title: Text("About", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
