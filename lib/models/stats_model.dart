class StatsModel {
  final int userId;
  final int totalRuns;
  final double totalDistanceKm;
  final int totalDurationSeconds;
  final int totalTrashCollected;
  final int totalCalories;
  final int totalExp;
  final int monthlyRuns;
  final double monthlyDistanceKm;
  final int monthlyDurationSeconds;
  final int monthlyTrashCollected;

  const StatsModel({
    required this.userId,
    required this.totalRuns,
    required this.totalDistanceKm,
    required this.totalDurationSeconds,
    required this.totalTrashCollected,
    required this.totalCalories,
    required this.totalExp,
    required this.monthlyRuns,
    required this.monthlyDistanceKm,
    required this.monthlyDurationSeconds,
    required this.monthlyTrashCollected,
  });

  factory StatsModel.empty() => const StatsModel(
        userId: 0,
        totalRuns: 0,
        totalDistanceKm: 0.0,
        totalDurationSeconds: 0,
        totalTrashCollected: 0,
        totalCalories: 0,
        totalExp: 0,
        monthlyRuns: 0,
        monthlyDistanceKm: 0.0,
        monthlyDurationSeconds: 0,
        monthlyTrashCollected: 0,
      );

  // Mock JSON
  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
        userId: json['userId'] as int,
        totalRuns: json['totalRuns'] as int,
        totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
        totalDurationSeconds: json['totalDurationSeconds'] as int,
        totalTrashCollected: json['totalTrashCollected'] as int,
        totalCalories: json['totalCalories'] as int,
        totalExp: json['totalExp'] as int,
        monthlyRuns: json['monthlyRuns'] as int,
        monthlyDistanceKm: (json['monthlyDistanceKm'] as num).toDouble(),
        monthlyDurationSeconds: json['monthlyDurationSeconds'] as int,
        monthlyTrashCollected: json['monthlyTrashCollected'] as int,
      );

  // Real API: GET /users/me/stats → {totalDistance, plogCount, totalExp, level}
  factory StatsModel.fromApiJson(Map<String, dynamic> json) => StatsModel(
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        totalRuns: (json['plogCount'] as num?)?.toInt() ??
            json['totalRuns'] as int? ?? 0,
        totalDistanceKm:
            (json['totalDistance'] as num?)?.toDouble() ??
                (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
        totalDurationSeconds:
            (json['totalDurationSeconds'] as num?)?.toInt() ?? 0,
        totalTrashCollected:
            (json['totalTrashCollected'] as num?)?.toInt() ?? 0,
        totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
        totalExp: (json['totalExp'] as num?)?.toInt() ?? 0,
        monthlyRuns:
            (json['monthlyRuns'] as num?)?.toInt() ??
                (json['plogCount'] as num?)?.toInt() ?? 0,
        monthlyDistanceKm:
            (json['monthlyDistanceKm'] as num?)?.toDouble() ??
                (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
        monthlyDurationSeconds:
            (json['monthlyDurationSeconds'] as num?)?.toInt() ?? 0,
        monthlyTrashCollected:
            (json['monthlyTrashCollected'] as num?)?.toInt() ?? 0,
      );

  String get monthlyDurationFormatted {
    final minutes = monthlyDurationSeconds ~/ 60;
    return '$minutes분';
  }

  String get totalExpFormatted {
    if (totalExp >= 1000) {
      final k = totalExp ~/ 1000;
      final r = totalExp % 1000;
      return '$k,${r.toString().padLeft(3, '0')}';
    }
    return '$totalExp';
  }
}
