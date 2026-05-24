import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/level_model.dart';
import '../models/stats_model.dart';

class AppState {
  static final AppState instance = AppState._();
  AppState._();

  UserModel? currentUser;
  LevelModel? userLevel;
  StatsModel? userStats;
  int? currentRunId;

  String _authToken = '';
  int _userId = 0;

  String get authToken => _authToken;
  int get userId => _userId;
  bool get isLoggedIn => currentUser != null && _authToken.isNotEmpty;

  // Called after OAuth: save token + userId, then fetch user profile
  Future<void> setAuth(String token, int userId) async {
    _authToken = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', userId);
  }

  // Restore session on cold start
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final id = prefs.getInt('user_id') ?? 0;
    if (token.isEmpty || id == 0) return false;
    _authToken = token;
    _userId = id;
    return true;
  }

  void setUser(UserModel user) {
    currentUser = user;
    _userId = user.id;
  }

  void setLevel(LevelModel level) => userLevel = level;
  void setStats(StatsModel stats) => userStats = stats;
  void setCurrentRunId(int? id) => currentRunId = id;

  Future<void> logout() async {
    currentUser = null;
    userLevel = null;
    userStats = null;
    currentRunId = null;
    _authToken = '';
    _userId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }
}
