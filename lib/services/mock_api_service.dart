import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../models/level_model.dart';
import '../models/stats_model.dart';
import '../models/run_model.dart';
import '../models/ranking_model.dart';
import '../models/badge_model.dart';
import '../models/trash_model.dart';
import '../models/exp_model.dart';

class MockApiService {
  static final MockApiService instance = MockApiService._();
  MockApiService._();

  static const _delay = Duration(milliseconds: 600);
  static const _shortDelay = Duration(milliseconds: 200);

  Future<Map<String, dynamic>> _load(String file) async {
    final raw = await rootBundle.loadString('assets/mock/$file');
    return json.decode(raw) as Map<String, dynamic>;
  }

  // ── /auth ─────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(_delay);
    return UserModel.fromJson(await _load('user.json'));
  }

  Future<UserModel> loginWithGoogle() async {
    await Future.delayed(_delay);
    return UserModel.fromJson(await _load('user.json'));
  }

  Future<UserModel> loginWithNaver() async {
    await Future.delayed(_delay);
    return UserModel.fromJson(await _load('user.json'));
  }

  Future<UserModel> signup(
      String email, String password, String nickname) async {
    await Future.delayed(_delay);
    return UserModel.fromJson(await _load('user.json'));
  }

  Future<void> logout() async {
    await Future.delayed(_shortDelay);
  }

  // ── /users/me ─────────────────────────────────────────────
  Future<UserModel> getMe() async {
    await Future.delayed(_delay);
    return UserModel.fromJson(await _load('user.json'));
  }

  Future<LevelModel> getMyLevel() async {
    await Future.delayed(_delay);
    return LevelModel.fromJson(await _load('level.json'));
  }

  Future<StatsModel> getMyStats() async {
    await Future.delayed(_delay);
    return StatsModel.fromJson(await _load('stats.json'));
  }

  // ── /runs ─────────────────────────────────────────────────
  Future<RunModel> startRun() async {
    await Future.delayed(_delay);
    return RunModel(
      id: 'run_live_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now().toIso8601String(),
      status: 'active',
      region: '서초동',
    );
  }

  Future<void> addLocation(String runId, double lat, double lng) async {
    await Future.delayed(_shortDelay);
  }

  Future<void> pauseRun(String runId) async {
    await Future.delayed(_shortDelay);
  }

  Future<void> resumeRun(String runId) async {
    await Future.delayed(_shortDelay);
  }

  Future<RunModel> endRun(
    String runId, {
    required int durationSeconds,
    required double distanceKm,
    required int calories,
    required int trashCollected,
  }) async {
    await Future.delayed(_delay);
    final expGained =
        (distanceKm * 20 + trashCollected * 10).round().clamp(0, 9999);
    return RunModel(
      id: runId,
      startedAt: DateTime.now()
          .subtract(Duration(seconds: durationSeconds))
          .toIso8601String(),
      endedAt: DateTime.now().toIso8601String(),
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      calories: calories,
      trashCollected: trashCollected,
      expGained: expGained,
      status: 'completed',
      region: '서초동',
    );
  }

  Future<RunModel> getRun(String runId) async {
    await Future.delayed(_delay);
    final data = await _load('runs.json');
    final runs = (data['runs'] as List)
        .map((e) => RunModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return runs.firstWhere((r) => r.id == runId, orElse: () => runs.first);
  }

  Future<List<RunModel>> getRuns() async {
    await Future.delayed(_delay);
    final data = await _load('runs.json');
    return (data['runs'] as List)
        .map((e) => RunModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── /trash ────────────────────────────────────────────────
  Future<TrashAnalyzeResult> analyzeTrash() async {
    // 더 긴 딜레이로 AI 분석 느낌
    await Future.delayed(const Duration(milliseconds: 1400));
    return TrashAnalyzeResult.fromJson(await _load('trash_analyze.json'));
  }

  Future<void> addTrashToRun(String runId, TrashAnalyzeResult result) async {
    await Future.delayed(_shortDelay);
  }

  Future<List<Map<String, dynamic>>> getTrashHistory() async {
    await Future.delayed(_delay);
    final data = await _load('trash_history.json');
    return List<Map<String, dynamic>>.from(data['history'] as List);
  }

  // ── /exp & /levels ────────────────────────────────────────
  Future<ExpModel> getExp() async {
    await Future.delayed(_delay);
    return ExpModel.fromJson(await _load('exp.json'));
  }

  Future<List<Map<String, dynamic>>> getLevels() async {
    await Future.delayed(_delay);
    final data = await _load('levels.json');
    return List<Map<String, dynamic>>.from(data['levels'] as List);
  }

  // ── /rankings ─────────────────────────────────────────────
  Future<RankingListModel> getGlobalRanking() async {
    await Future.delayed(_delay);
    return RankingListModel.fromJson(await _load('rankings_global.json'));
  }

  Future<RankingListModel> getRegionRanking() async {
    await Future.delayed(_delay);
    return RankingListModel.fromJson(await _load('rankings_region.json'));
  }

  Future<MyRankingModel> getMyRanking() async {
    await Future.delayed(_delay);
    return MyRankingModel.fromJson(await _load('rankings_me.json'));
  }

  // ── /badges ───────────────────────────────────────────────
  Future<List<BadgeModel>> getBadges() async {
    await Future.delayed(_delay);
    final data = await _load('badges.json');
    return (data['badges'] as List)
        .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── /settings ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getNotificationSettings() async {
    await Future.delayed(_shortDelay);
    return {'pushEnabled': true, 'runReminder': true, 'rankingUpdate': false};
  }

  Future<Map<String, dynamic>> getLocationSettings() async {
    await Future.delayed(_shortDelay);
    return {'shareLocation': true, 'autoPause': true};
  }
}
