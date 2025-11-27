// screens/lesson_details_screen.dart
import 'package:flutter/material.dart';
import '../models/lesson.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Lesson Title ----
              Text(
                lesson.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // ---- Lesson Description ----
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  lesson.description,
                  style: const TextStyle(
                      fontSize: 16, height: 1.6, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 20),

              // ---- Actionable Tip ----
              Text(
                "Actionable Tip",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.actionableTip,
                style: const TextStyle(
                    fontSize: 16, height: 1.6, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              // ---- Reflection Prompt ----
              Text(
                "Reflection Prompt",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.reflectionPrompt,
                style: const TextStyle(
                    fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
