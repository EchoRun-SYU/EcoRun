import 'package:flutter/material.dart';

class TrashAnalyzeItem {
  final String id;
  final String trashType;
  final String iconKey;
  final int count;
  final int expEach;
  final int totalExp;

  const TrashAnalyzeItem({
    required this.id,
    required this.trashType,
    required this.iconKey,
    required this.count,
    required this.expEach,
    required this.totalExp,
  });

  factory TrashAnalyzeItem.fromJson(Map<String, dynamic> json) =>
      TrashAnalyzeItem(
        id: json['id'] as String,
        trashType: json['trashType'] as String,
        iconKey: json['iconKey'] as String,
        count: json['count'] as int,
        expEach: json['expEach'] as int,
        totalExp: json['totalExp'] as int,
      );

  IconData get icon {
    switch (iconKey) {
      case 'local_drink':
        return Icons.local_drink_outlined;
      case 'smoking_rooms':
        return Icons.smoking_rooms_outlined;
      case 'delete':
        return Icons.delete_outline_rounded;
      case 'eco':
        return Icons.eco_rounded;
      default:
        return Icons.delete_outline_rounded;
    }
  }
}

class TrashAnalyzeResult {
  final bool success;
  final int totalCount;
  final int totalExp;
  final List<TrashAnalyzeItem> items;

  const TrashAnalyzeResult({
    required this.success,
    required this.totalCount,
    required this.totalExp,
    required this.items,
  });

  // Mock JSON
  factory TrashAnalyzeResult.fromJson(Map<String, dynamic> json) =>
      TrashAnalyzeResult(
        success: json['success'] as bool,
        totalCount: json['totalCount'] as int,
        totalExp: json['totalExp'] as int,
        items: (json['items'] as List)
            .map((e) =>
                TrashAnalyzeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // Real API: POST /trash/analyze → {trashType, pointsEarned, confidence, message}
  factory TrashAnalyzeResult.fromApiJson(Map<String, dynamic> json) {
    final trashType = json['trashType'] as String? ?? '쓰레기';
    final points = (json['pointsEarned'] as num?)?.toInt() ?? 10;
    final item = TrashAnalyzeItem(
      id: 'api_1',
      trashType: trashType,
      iconKey: _iconKeyFor(trashType),
      count: 1,
      expEach: points,
      totalExp: points,
    );
    return TrashAnalyzeResult(
      success: true,
      totalCount: 1,
      totalExp: points,
      items: [item],
    );
  }

  static String _iconKeyFor(String trashType) {
    final t = trashType.toLowerCase();
    if (t.contains('담배') || t.contains('cigarette')) return 'smoking_rooms';
    if (t.contains('음료') || t.contains('컵') || t.contains('bottle')) {
      return 'local_drink';
    }
    if (t.contains('유기') || t.contains('organic') || t.contains('음식')) {
      return 'eco';
    }
    return 'delete';
  }
}
