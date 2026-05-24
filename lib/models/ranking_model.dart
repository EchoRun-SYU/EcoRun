import 'package:flutter/material.dart';

class RankingEntry {
  final int rank;
  final int userId;
  final String nickname;
  final String levelName;
  final int level;
  final int weeklyExp;
  final bool isMe;

  const RankingEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    required this.levelName,
    required this.level,
    required this.weeklyExp,
    this.isMe = false,
  });

  // Mock JSON
  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
        rank: json['rank'] as int,
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
        levelName: json['levelName'] as String,
        level: json['level'] as int,
        weeklyExp: json['weeklyExp'] as int,
        isMe: json['isMe'] as bool? ?? false,
      );

  // Real API: GET /rankings/* → {rank, userId, nickname, region, level, levelTitle, exp, totalDistance, plogCount}
  factory RankingEntry.fromApiJson(Map<String, dynamic> json,
      {bool isMe = false}) =>
      RankingEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        nickname: json['nickname'] as String? ?? '',
        levelName: json['levelTitle'] as String? ??
            json['levelName'] as String? ?? '',
        level: (json['level'] as num?)?.toInt() ?? 1,
        weeklyExp: (json['exp'] as num?)?.toInt() ?? 0,
        isMe: isMe,
      );

  Color get podiumColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFB0B0B0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get levelDisplay => '$levelName · Lv.$level';
}

class RankingListModel {
  final int week;
  final String type;
  final String region;
  final String updatedAt;
  final List<RankingEntry> rankings;

  const RankingListModel({
    required this.week,
    required this.type,
    required this.region,
    required this.updatedAt,
    required this.rankings,
  });

  factory RankingListModel.empty() => RankingListModel(
        week: 0,
        type: '',
        region: '',
        updatedAt: '',
        rankings: [],
      );

  factory RankingListModel.fromJson(Map<String, dynamic> json) =>
      RankingListModel(
        week: json['week'] as int,
        type: json['type'] as String,
        region: json['region'] as String,
        updatedAt: json['updatedAt'] as String,
        rankings: (json['rankings'] as List)
            .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  List<RankingEntry> get top3 {
    final top = rankings.where((r) => r.rank <= 3).toList();
    const order = {2: 0, 1: 1, 3: 2};
    top.sort((a, b) => (order[a.rank] ?? 9).compareTo(order[b.rank] ?? 9));
    return top;
  }

  List<RankingEntry> get leaderboard =>
      rankings.where((r) => r.rank > 3).toList();
}

class MyRankingModel {
  final int globalRank;
  final int regionRank;
  final String region;
  final int weeklyExp;

  const MyRankingModel({
    required this.globalRank,
    required this.regionRank,
    required this.region,
    required this.weeklyExp,
  });

  factory MyRankingModel.fromJson(Map<String, dynamic> json) =>
      MyRankingModel(
        globalRank: json['globalRank'] as int,
        regionRank: json['regionRank'] as int,
        region: json['region'] as String,
        weeklyExp: json['weeklyExp'] as int,
      );
}
