class ExpHistoryEntry {
  final int id;
  final int amount;
  final String source;
  final String description;
  final String earnedAt;

  const ExpHistoryEntry({
    required this.id,
    required this.amount,
    required this.source,
    required this.description,
    required this.earnedAt,
  });

  factory ExpHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ExpHistoryEntry(
        id: json['id'] as int,
        amount: json['amount'] as int,
        source: json['source'] as String,
        description: json['description'] as String,
        earnedAt: json['earnedAt'] as String,
      );
}

class ExpModel {
  final int userId;
  final int totalExp;
  final int weeklyExp;
  final List<ExpHistoryEntry> recentHistory;

  const ExpModel({
    required this.userId,
    required this.totalExp,
    required this.weeklyExp,
    required this.recentHistory,
  });

  factory ExpModel.fromJson(Map<String, dynamic> json) => ExpModel(
        userId: json['userId'] as int,
        totalExp: json['totalExp'] as int,
        weeklyExp: json['weeklyExp'] as int,
        recentHistory: (json['recentHistory'] as List)
            .map((e) => ExpHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
