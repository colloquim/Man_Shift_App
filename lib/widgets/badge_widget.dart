// widgets/badge_widget.dart
import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool completed;

  const BadgeWidget({
    super.key,
    required this.title,
    required this.icon,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: completed ? Colors.teal : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: completed ? Colors.white : Colors.black54,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: completed ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
