import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/stats_model.dart';
import '../models/level_model.dart';
import '../models/ranking_model.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'main_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StatsModel? _stats;
  LevelModel? _level;
  MyRankingModel? _myRanking;
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
    late MyRankingModel myRanking;

    try {
      await Future.wait([
        api.getMyStats().then((v) => stats = v),
        api.getMyLevel().then((v) {
          level = v;
          AppState.instance.setLevel(v);
        }),
        api.getMyRanking().then((v) => myRanking = v),
      ]);
    } catch (e) {
      debugPrint('HomeScreen 데이터 로드 실패: $e');
      stats = StatsModel.empty();
      level = AppState.instance.userLevel ?? LevelModel.empty();
      myRanking = MyRankingModel(globalRank: 0, regionRank: 0, region: '', weeklyExp: 0);
    }

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _level = level;
      _myRanking = myRanking;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nickname =
        AppState.instance.currentUser?.nickname ?? '에코러너';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryContainer))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '안녕하세요,',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                '$nickname님!',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline_rounded,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Start plogging banner
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const MainScaffold(initialIndex: 1)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_run_rounded,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '오늘도 플로깅 시작할까요?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.onPrimaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader(context, '이번 주 기록 확인이 필요한가요?'),
                    const SizedBox(height: 12),
                    _weeklyStatsCard(context),
                    const SizedBox(height: 16),
                    _levelCard(context),
                    const SizedBox(height: 24),
                    _sectionHeader(context, '이번 주 랭킹 확인이 필요한가요?'),
                    const SizedBox(height: 12),
                    _rankingPreviewCard(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      );

  Widget _weeklyStatsCard(BuildContext context) {
    final month = DateTime.now().month;
    final runs = _stats?.monthlyRuns ?? 0;
    final duration = _stats?.monthlyDurationFormatted ?? '-';
    final dist =
        '${(_stats?.monthlyDistanceKm ?? 0).toStringAsFixed(1)}km';

    return _card(
      child: Row(
        children: [
          const Icon(Icons.eco_rounded,
              color: AppColors.primaryContainer, size: 20),
          const SizedBox(width: 8),
          Text('$month월 플로깅',
              style: Theme.of(context).textTheme.labelMedium),
          const Spacer(),
          _statItem(context, '$runs번', '총 횟수'),
          _divider(),
          _statItem(context, duration, '총 시간'),
          _divider(),
          _statItem(context, dist, '총 거리'),
        ],
      ),
    );
  }

  Widget _levelCard(BuildContext context) {
    final level = _level;
    final levelNum = level?.currentLevel ?? 0;
    final levelName = level?.levelName ?? '-';
    final progress = level?.progress ?? 0.0;
    final expToNext = level?.expToNextLevel ?? 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.primaryContainer, size: 20),
              const SizedBox(width: 8),
              Text(
                'Level $levelNum',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '다음 레벨까지 $expToNext EXP',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryContainer),
            ),
          ),
          const SizedBox(height: 6),
          Text(levelName, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _rankingPreviewCard(BuildContext context) {
    final region = _myRanking?.region ?? '-';
    final rank = _myRanking?.regionRank ?? 0;

    return _card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$region LOCAL',
                  style: Theme.of(context).textTheme.labelMedium),
              Text(
                '지역 랭킹 $rank위',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryContainer,
                    ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            label,
            style:
                Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppColors.outlineVariant);

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
