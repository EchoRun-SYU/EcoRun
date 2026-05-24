import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconKey;
  final String? earnedAt;
  final bool earned;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    this.earnedAt,
    required this.earned,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconKey: json['iconKey'] as String,
        earnedAt: json['earnedAt'] as String?,
        earned: json['earned'] as bool,
      );

  IconData get icon {
    switch (iconKey) {
      case 'eco':
        return Icons.eco_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'delete_outline':
        return Icons.delete_outline_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  Color get badgeColor {
    switch (id) {
      case 'top10':
        return const Color(0xFFFFD700);
      case 'trash_king':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}
