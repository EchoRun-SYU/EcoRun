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

  // 백엔드 레벨 임계값 미러 (UserLevelResponse.java getNextLevelExp 기준)
  static const List<int> _levelThresholds = [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200];

  // Real API: GET /users/me/level → {level, levelTitle, currentExp, nextLevelExp}
  factory LevelModel.fromApiJson(Map<String, dynamic> json) {
    final level = (json['level'] as num?)?.toInt() ??
        (json['currentLevel'] as num?)?.toInt() ?? 1;
    final prevExp = (level - 1) < _levelThresholds.length
        ? _levelThresholds[(level - 1).clamp(0, _levelThresholds.length - 1)]
        : _levelThresholds.last;
    return LevelModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      currentLevel: level,
      levelName: json['levelTitle'] as String? ??
          json['levelName'] as String? ?? '',
      currentExp: (json['currentExp'] as num?)?.toInt() ?? 0,
      nextLevelExp: (json['nextLevelExp'] as num?)?.toInt() ?? 1,
      prevLevelExp: prevExp,
    );
  }

  double get progress {
    final range = nextLevelExp - prevLevelExp;
    if (range <= 0) return 1.0;
    return ((currentExp - prevLevelExp) / range).clamp(0.0, 1.0);
  }

  int get expToNextLevel => (nextLevelExp - currentExp).clamp(0, 999999);

  String get displayLabel => 'LV.$currentLevel $levelName';
}
