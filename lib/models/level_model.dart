class LevelModel {
  final int userId;
  final int currentLevel;
  final String levelName;
  final int currentExp;
  final int nextLevelExp;
  final int prevLevelExp;

  const LevelModel({
    required this.userId,
    required this.currentLevel,
    required this.levelName,
    required this.currentExp,
    required this.nextLevelExp,
    required this.prevLevelExp,
  });

  factory LevelModel.empty() => const LevelModel(
        userId: 0,
        currentLevel: 1,
        levelName: '',
        currentExp: 0,
        nextLevelExp: 100,
        prevLevelExp: 0,
      );

  // Mock JSON
  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
        userId: json['userId'] as int,
        currentLevel: json['currentLevel'] as int,
        levelName: json['levelName'] as String,
        currentExp: json['currentExp'] as int,
        nextLevelExp: json['nextLevelExp'] as int,
        prevLevelExp: json['prevLevelExp'] as int,
      );

  // Real API: GET /users/me/level → {level, levelTitle, currentExp, nextLevelExp}
  factory LevelModel.fromApiJson(Map<String, dynamic> json) => LevelModel(
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        currentLevel: (json['level'] as num?)?.toInt() ??
            json['currentLevel'] as int? ?? 1,
        levelName: json['levelTitle'] as String? ??
            json['levelName'] as String? ?? '',
        currentExp: (json['currentExp'] as num?)?.toInt() ?? 0,
        nextLevelExp: (json['nextLevelExp'] as num?)?.toInt() ?? 1,
        prevLevelExp: (json['prevLevelExp'] as num?)?.toInt() ?? 0,
      );

  double get progress {
    final range = nextLevelExp - prevLevelExp;
    if (range <= 0) return 1.0;
    return ((currentExp - prevLevelExp) / range).clamp(0.0, 1.0);
  }

  int get expToNextLevel => (nextLevelExp - currentExp).clamp(0, 999999);

  String get displayLabel => 'LV.$currentLevel $levelName';
}
