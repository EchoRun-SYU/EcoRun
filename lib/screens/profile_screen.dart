import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/stats_model.dart';
import '../models/level_model.dart';
import '../models/badge_model.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StatsModel? _stats;
  LevelModel? _level;
  List<BadgeModel>? _badges;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiService.instance;
    late StatsModel stats;
    late LevelModel level;

    try {
      await Future.wait([
        api.getMyStats().then((v) => stats = v),
        api.getMyLevel().then((v) => level = v),
      ]);
    } catch (e) {
      debugPrint('ProfileScreen 데이터 로드 실패: $e');
      stats = StatsModel.empty();
      level = AppState.instance.userLevel ?? LevelModel.empty();
    }

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _level = level;
      _badges = _computeBadges(stats);
      _loading = false;
    });
  }

  List<BadgeModel> _computeBadges(StatsModel stats) {
    final earned = <BadgeModel>[];
    if (stats.totalRuns >= 1) {
      earned.add(const BadgeModel(
        id: 'first_run', name: '첫 걸음',
        description: '첫 번째 플로깅 완료', iconKey: 'eco', earned: true,
      ));
    }
    if (stats.totalDistanceKm >= 5.0) {
      earned.add(const BadgeModel(
        id: '5k_runner', name: '5K 러너',
        description: '누적 5km 달성', iconKey: 'directions_run', earned: true,
      ));
    }
    if (stats.totalTrashCollected >= 10) {
      earned.add(const BadgeModel(
        id: 'trash_king', name: '쓰레기 전사',
        description: '쓰레기 10개 수거', iconKey: 'delete_outline', earned: true,
      ));
    }
    if (stats.totalRuns >= 5) {
      earned.add(const BadgeModel(
        id: 'regular', name: '꾸준한 러너',
        description: '5회 플로깅 완료', iconKey: 'emoji_events', earned: true,
      ));
    }
    if (stats.totalDistanceKm >= 10.0) {
      earned.add(const BadgeModel(
        id: '10k_runner', name: '10K 러너',
        description: '누적 10km 달성', iconKey: 'star', earned: true,
      ));
    }
    return earned;
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.currentUser;
    final level = _level;
    final stats = _stats;
    final earnedBadges =
        _badges?.where((b) => b.earned).toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryContainer))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Text('내 프로필',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ),
                            icon: const Icon(Icons.settings_outlined,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // Profile card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryContainer,
                              AppColors.primary
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user?.nickname ?? '에코러너',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                level != null
                                    ? 'LV.${level.currentLevel} ${level.levelName}'
                                    : '-',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // EXP progress
                            Row(
                              children: [
                                Text(
                                  '${level?.currentExp ?? 0} EXP',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(
                                  '${((level?.progress ?? 0) * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '다음 레벨까지 ${level?.expToNextLevel ?? 0} EXP',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:
                                    (level?.progress ?? 0).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withAlpha(50),
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('활동 통계',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('이번 달 기준',
                              style:
                                  Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.6,
                            children: [
                              _statCard(
                                context,
                                Icons.directions_run_rounded,
                                '달성 거리',
                                '${stats?.totalDistanceKm.toStringAsFixed(1) ?? '-'} KM',
                                AppColors.primaryContainer,
                              ),
                              _statCard(
                                context,
                                Icons.repeat_rounded,
                                '미션 완료',
                                '${stats?.totalRuns ?? '-'} 회',
                                AppColors.secondaryContainer,
                              ),
                              _statCard(
                                context,
                                Icons.delete_outline_rounded,
                                '수거량',
                                '${stats?.totalTrashCollected ?? '-'} 개',
                                AppColors.primaryContainer,
                              ),
                              _statCard(
                                context,
                                Icons.bolt_rounded,
                                '총 EXP',
                                stats?.totalExpFormatted ?? '-',
                                AppColors.secondaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Badges
                    if (earnedBadges.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('최근 뱃지',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${earnedBadges.length}개 달성',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: earnedBadges
                                  .take(4)
                                  .map((b) => _badge(context, b))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800, fontSize: 20)),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, BadgeModel badge) {
    final color = badge.badgeColor;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(80), width: 2),
          ),
          child: Icon(badge.icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(badge.name,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontSize: 11)),
      ],
    );
  }
}
