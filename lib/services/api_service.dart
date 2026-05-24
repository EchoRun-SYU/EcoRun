import 'dart:convert';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/level_model.dart';
import '../models/stats_model.dart';
import '../models/run_model.dart';
import '../models/ranking_model.dart';
import '../models/trash_model.dart';
import '../state/app_state.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  static const _base = 'https://echorun-server-production.up.railway.app';

  Map<String, String> get _headers {
    final token = AppState.instance.authToken;
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? params}) async {
    final uri = Uri.parse('$_base$path')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    _check(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path,
      {Map<String, String>? params}) async {
    final uri = Uri.parse('$_base$path')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers);
    _check(res);
    return json.decode(res.body) as List;
  }

  Future<Map<String, dynamic>> _post(String path,
      {Map<String, dynamic>? body,
      Map<String, String>? params}) async {
    final uri = params != null
        ? Uri.parse('$_base$path').replace(queryParameters: params)
        : Uri.parse('$_base$path');
    final res = await http.post(uri,
        headers: _headers, body: body != null ? json.encode(body) : null);
    _check(res);
    if (res.body.isEmpty) return {};
    return json.decode(res.body) as Map<String, dynamic>;
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }
  }

  // ── auth ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> loginWithGoogleToken(String idToken,
      {String? nickname}) async {
    return _post('/auth/google/token', body: {
      'idToken': idToken,
      'nickname': ?nickname,
    });
  }

  // ── users ──────────────────────────────────────────────────
  Future<UserModel> getMe() async {
    final data = await _get('/users/me',
        params: {'userId': '${AppState.instance.userId}'});
    return UserModel.fromApiJson(data,
        token: AppState.instance.authToken);
  }

  Future<LevelModel> getMyLevel() async {
    final data = await _get('/users/me/level',
        params: {'userId': '${AppState.instance.userId}'});
    return LevelModel.fromApiJson(data);
  }

  Future<StatsModel> getMyStats() async {
    final userId = AppState.instance.userId;
    final results = await Future.wait([
      _get('/users/me/stats', params: {'userId': '$userId'}),
      _getList('/runs', params: {'userId': '$userId'}),
    ]);

    final statsData = results[0] as Map<String, dynamic>;
    final runsList = (results[1] as List).cast<Map<String, dynamic>>();

    final now = DateTime.now();
    final monthlyRuns = runsList.where((r) {
      final raw = r['startTime'] as String? ?? r['startedAt'] as String? ?? '';
      final dt = DateTime.tryParse(raw);
      return dt != null &&
          dt.year == now.year &&
          dt.month == now.month &&
          (r['status'] as String? ?? '') == 'completed';
    }).toList();

    return StatsModel.fromApiJson(
      statsData,
      monthlyRuns: monthlyRuns.length,
      monthlyDistanceKm: monthlyRuns.fold(
          0.0, (s, r) => s + ((r['distance'] as num?)?.toDouble() ?? 0)),
      monthlyDurationSeconds: monthlyRuns.fold(
          0, (s, r) => s + ((r['duration'] as num?)?.toInt() ?? 0)),
      monthlyTrashCollected: monthlyRuns.fold(
          0, (s, r) => s + ((r['trashCount'] as num?)?.toInt() ?? 0)),
    );
  }

  // ── runs ───────────────────────────────────────────────────
  Future<int> startRun() async {
    final data = await _post('/runs/start');
    return (data['runId'] as num).toInt();
  }

  Future<void> endRun(int runId,
      {required double distance,
      required int duration,
      List<LatLng> routePoints = const []}) async {
    await _post('/runs/$runId/end', body: {
      'distance': distance,
      'duration': duration,
      'route': routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    });
  }

  Future<List<RunModel>> getRuns() async {
    final list = await _getList('/runs',
        params: {'userId': '${AppState.instance.userId}'});
    return list
        .map((e) => RunModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RunModel> getRun(int runId) async {
    final data = await _get('/runs/$runId');
    return RunModel.fromApiJson(data);
  }

  // ── trash ──────────────────────────────────────────────────
  Future<TrashAnalyzeResult> analyzeTrash(Uint8List imageBytes) async {
    final uri = Uri.parse('$_base/trash/analyze');
    final request = http.MultipartRequest('POST', uri);
    final token = AppState.instance.authToken;
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes(
      'image', imageBytes,
      filename: 'trash.jpg',
    ));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _check(res);
    return TrashAnalyzeResult.fromApiJson(
        json.decode(res.body) as Map<String, dynamic>);
  }

  Future<void> addTrashToRun(int runId, int trashCount,
      {String photoUrl = ''}) async {
    await _post(
      '/runs/$runId/trash',
      body: {'trashCount': trashCount, 'photoUrl': photoUrl},
      params: {'userId': '${AppState.instance.userId}'},
    );
  }

  // ── exp ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> addExp(int amount) async {
    return _post('/exp',
        body: {'amount': amount},
        params: {'userId': '${AppState.instance.userId}'});
  }

  // ── rankings ───────────────────────────────────────────────
  Future<RankingListModel> getGlobalRanking() async {
    final list = await _getList('/rankings/global');
    return _buildRankingModel(list, 'global', '전국');
  }

  Future<RankingListModel> getRegionRanking() async {
    final region = AppState.instance.currentUser?.region ?? '';
    final list = await _getList('/rankings/region',
        params: {'region': region});
    return _buildRankingModel(list, 'region', region);
  }

  Future<MyRankingModel> getMyRanking() async {
    try {
      final myId = AppState.instance.userId;
      final region = AppState.instance.currentUser?.region ?? '';
      final globalList = await _getList('/rankings/global');
      final regionList = region.isNotEmpty
          ? await _getList('/rankings/region', params: {'region': region})
          : <dynamic>[];

      final globalEntry = globalList
          .cast<Map<String, dynamic>>()
          .where((e) => (e['userId'] as num?)?.toInt() == myId)
          .firstOrNull;
      final regionEntry = regionList
          .cast<Map<String, dynamic>>()
          .where((e) => (e['userId'] as num?)?.toInt() == myId)
          .firstOrNull;

      return MyRankingModel(
        globalRank: (globalEntry?['rank'] as num?)?.toInt() ?? 0,
        regionRank: (regionEntry?['rank'] as num?)?.toInt() ?? 0,
        region: region,
        weeklyExp: (globalEntry?['exp'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return MyRankingModel(
          globalRank: 0, regionRank: 0, region: '', weeklyExp: 0);
    }
  }

  RankingListModel _buildRankingModel(
      List<dynamic> list, String type, String region) {
    final myId = AppState.instance.userId;
    final entries = list.map((e) {
      final m = e as Map<String, dynamic>;
      return RankingEntry.fromApiJson(m,
          isMe: (m['userId'] as num?)?.toInt() == myId);
    }).toList();
    return RankingListModel(
      week: _isoWeekNumber(DateTime.now()),
      type: type,
      region: region,
      updatedAt: DateTime.now().toIso8601String(),
      rankings: entries,
    );
  }

  int _isoWeekNumber(DateTime date) {
    final doy = int.parse(
        '${date.difference(DateTime(date.year, 1, 1)).inDays + 1}');
    return ((doy - date.weekday + 10) / 7).floor();
  }
}

// JWT payload decoder (no verification — client-side only)
int decodeUserIdFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return 0;
    final payload =
        base64Url.decode(base64Url.normalize(parts[1]));
    final data =
        json.decode(utf8.decode(payload)) as Map<String, dynamic>;
    return (data['sub'] != null
            ? int.tryParse(data['sub'].toString()) ?? 0
            : (data['userId'] as num?)?.toInt()) ??
        0;
  } catch (_) {
    return 0;
  }
}
