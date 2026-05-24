import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/ranking_model.dart';
import '../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RankingListModel? _globalRanking;
  RankingListModel? _regionRanking;
  MyRankingModel? _myRanking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final api = ApiService.instance;
    RankingListModel global = RankingListModel.empty();
    RankingListModel region = RankingListModel.empty();
    MyRankingModel me = MyRankingModel(globalRank: 0, regionRank: 0, region: '', weeklyExp: 0);

    try {
      await Future.wait([
        api.getGlobalRanking().then((v) => global = v),
        api.getRegionRanking().then((v) => region = v),
        api.getMyRanking().then((v) => me = v),
      ]);
    } catch (e) {
      debugPrint('RankingScreen 데이터 로드 실패: $e');
    }

    if (!mounted) return;
    setState(() {
      _globalRanking = global;
      _regionRanking = region;
      _myRanking = me;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myRanking = _myRanking;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text('RANKING',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        'WEEK ${_globalRanking?.week ?? '-'}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  padding: const EdgeInsets.all(4),
                  tabs: const [Tab(text: 'LOCAL'), Tab(text: 'CITY')],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 16, color: AppColors.primaryContainer),
                  const SizedBox(width: 4),
                  Text(
                    _regionRanking?.region ?? '서초동',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryContainer))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_regionRanking),
                        _buildList(_globalRanking),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: myRanking != null
          ? _myRankBanner(context, myRanking)
          : null,
    );
  }

  Widget _buildList(RankingListModel? ranking) {
    if (ranking == null) return const SizedBox.shrink();
    final top3 = ranking.top3;
    final leaderboard = ranking.leaderboard;
    final region = ranking.region;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOP RUNNERS',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text('$region 기준',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: top3.map((r) => _podiumItem(r)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text('LEADERBOARD',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const Spacer(),
                      Text('WEEKLY EXP',
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
                ...leaderboard.map((item) => _leaderboardItem(item)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _podiumItem(RankingEntry r) {
    final isFirst = r.rank == 1;
    final avatarSize = isFirst ? 64.0 : 52.0;
    final color = r.podiumColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(Icons.workspace_premium_rounded,
              color: Color(0xFFFFD700), size: 24),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(40),
            border: Border.all(color: color, width: 2),
          ),
          child: const Icon(Icons.person_rounded,
              color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Text(r.nickname,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        Text('${r.weeklyExp} EXP',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text('${r.rank}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _leaderboardItem(RankingEntry item) {
    final isMe = item.isMe;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryContainer.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${item.rank}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isMe
                        ? AppColors.primaryContainer
                        : AppColors.onSurface,
                  ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primaryContainer.withAlpha(40)
                  : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded,
                size: 20,
                color: isMe
                    ? AppColors.primaryContainer
                    : AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nickname,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(item.levelDisplay,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 14, color: AppColors.primaryContainer),
              Text(
                ' ${item.weeklyExp}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer,
                    ),
              ),
              Text(' EXP',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myRankBanner(BuildContext context, MyRankingModel myRanking) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(20),
        border: Border(
            top: BorderSide(color: AppColors.primaryContainer.withAlpha(40))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('내 순위',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Text('${myRanking.region} ${myRanking.regionRank}위',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.primary)),
            const Spacer(),
            const Icon(Icons.bolt_rounded,
                size: 16, color: AppColors.primaryContainer),
            Text(' ${myRanking.weeklyExp}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.primaryContainer)),
            Text(' EXP',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
