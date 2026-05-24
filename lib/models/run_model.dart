class RunModel {
  final String id;
  final String startedAt;
  final String? endedAt;
  final int? durationSeconds;
  final double? distanceKm;
  final int? calories;
  final int? trashCollected;
  final int? expGained;
  final String status;
  final String region;

  const RunModel({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.distanceKm,
    this.calories,
    this.trashCollected,
    this.expGained,
    required this.status,
    this.region = '서초동',
  });

  // Mock JSON
  factory RunModel.fromJson(Map<String, dynamic> json) => RunModel(
        id: json['id'] as String,
        startedAt: json['startedAt'] as String,
        endedAt: json['endedAt'] as String?,
        durationSeconds: json['durationSeconds'] as int?,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        calories: json['calories'] as int?,
        trashCollected: json['trashCollected'] as int?,
        expGained: json['expGained'] as int?,
        status: json['status'] as String,
        region: json['region'] as String? ?? '서초동',
      );

  // Real API: GET /runs/{runId} → {id, distance, duration, pace, calories, startTime, endTime, status, trashCount}
  factory RunModel.fromApiJson(Map<String, dynamic> json) => RunModel(
        id: (json['id'] as num).toInt().toString(),
        startedAt: json['startTime'] as String? ??
            json['startedAt'] as String? ??
            DateTime.now().toIso8601String(),
        endedAt: json['endTime'] as String? ?? json['endedAt'] as String?,
        durationSeconds: (json['duration'] as num?)?.toInt() ??
            json['durationSeconds'] as int?,
        distanceKm: (json['distance'] as num?)?.toDouble() ??
            (json['distanceKm'] as num?)?.toDouble(),
        calories: (json['calories'] as num?)?.toInt(),
        trashCollected: (json['trashCount'] as num?)?.toInt() ??
            json['trashCollected'] as int?,
        expGained: (json['expGiven'] as num?)?.toInt() ??
            json['expGained'] as int?,
        status: json['status'] as String? ?? 'completed',
        region: json['region'] as String? ?? '서초동',
      );
}
