// models/user_badge.dart
class UserBadge {
  final String id;
  final String title;
  final String description;
  final String icon;

  UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) => UserBadge(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
      };
}
