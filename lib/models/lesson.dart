// models/lesson.dart
class Lesson {
  String title;
  String description;
  String actionableTip;
  String reflectionPrompt;
  int dayIndex;
  bool completed;
  String? reflection;

  Lesson({
    required this.title,
    required this.description,
    required this.actionableTip,
    required this.reflectionPrompt,
    required this.dayIndex,
    this.completed = false,
    this.reflection,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'actionableTip': actionableTip,
        'reflectionPrompt': reflectionPrompt,
        'dayIndex': dayIndex,
        'completed': completed,
        'reflection': reflection,
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        title: json['title'],
        description: json['description'],
        actionableTip: json['actionableTip'],
        reflectionPrompt: json['reflectionPrompt'],
        dayIndex: json['dayIndex'],
        completed: json['completed'] ?? false,
        reflection: json['reflection'],
      );
}
