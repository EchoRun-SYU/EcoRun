import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/run_model.dart';
import '../services/api_service.dart';
import 'record_detail_screen.dart';

class MyRecordsScreen extends StatefulWidget {
  const MyRecordsScreen({super.key});

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  List<RunModel>? _runs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await ApiService.instance.getRuns();
      final completed = all
          .where((r) => (r.distanceKm ?? 0) > 0)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      if (!mounted) return;
      setState(() {
        _runs = completed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '기록을 불러올 수 없어요';
        _loading = false;
      });
    }
  }

  static String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _formatDate(String iso) {
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final wd = weekdays[d.weekday - 1];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}월 ${d.day}일 $wd요일 $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final runs = _runs ?? [];
    final totalDistance = runs.fold(0.0, (s, r) => s + (r.distanceKm ?? 0));
    final totalCollected = runs.fold(0, (s, r) => s + (r.trashCollected ?? 0));
    final totalExp = runs.fold(0, (s, r) => s + (r.expGained ?? 0));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('내 기록', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outlineVariant.withAlpha(80)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primaryContainer,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (runs.isNotEmpty) ...[
                          _buildSummaryCard(totalDistance, totalCollected, totalExp),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          children: [
                            Text('기록 목록',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Text('${runs.length}건',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (runs.isEmpty)
                          _buildEmpty(context)
                        else
                          ...runs.map((r) => _RunCard(
                                run: r,
                                formatTime: _formatTime,
                                formatDate: _formatDate,
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(double distance, int collected, int exp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('전체 누적 기록',
              style: TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem(distance.toStringAsFixed(1), '총 거리 KM'),
              _summaryItem(collected.toString(), '총 수거 개'),
              _summaryItem(exp.toString(), '총 EXP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text('🏃', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('아직 기록이 없어요',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('플로깅을 완료하면 여기에 기록이 쌓여요!',
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.outline, fontSize: 14)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _load();
            },
            child: const Text('다시 시도',
                style: TextStyle(color: AppColors.primaryContainer)),
          ),
        ],
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  final RunModel run;
  final String Function(int) formatTime;
  final String Function(String) formatDate;

  const _RunCard({
    required this.run,
    required this.formatTime,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final duration = run.durationSeconds ?? 0;
    final distance = run.distanceKm ?? 0.0;
    final paceSeconds = distance > 0 ? (duration / distance).round() : 0;
    final paceMin = paceSeconds ~/ 60;
    final paceSec = (paceSeconds % 60).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecordDetailScreen(run: run)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatDate(run.startedAt),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                  ),
                ),
                if ((run.expGained ?? 0) > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 11, color: AppColors.secondaryContainer),
                        const SizedBox(width: 2),
                        Text('+${run.expGained} EXP',
                            style: const TextStyle(
                                color: AppColors.secondaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.outlineVariant),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _statChip(Icons.map_outlined, AppColors.primaryContainer,
                    distance.toStringAsFixed(2), 'KM'),
                _statChip(Icons.access_time_rounded, AppColors.primaryContainer,
                    formatTime(duration), '시간'),
                _statChip(Icons.local_fire_department_rounded,
                    AppColors.secondaryContainer, '${run.calories ?? 0}',
                    'kcal'),
                _statChip(Icons.eco_rounded, AppColors.primaryContainer,
                    '${run.trashCollected ?? 0}', '수거'),
              ],
            ),
            if (paceSeconds > 0) ...[
              const Divider(height: 28, color: AppColors.outlineVariant),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 11,
                        fontFamily: 'PlusJakartaSans'),
                    children: [
                      const TextSpan(text: '평균 페이스  '),
                      TextSpan(
                        text: "$paceMin'$paceSec\"",
                        style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                      const TextSpan(text: '  / km'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: AppColors.outline, fontSize: 9)),
        ],
      ),
    );
  }
}
