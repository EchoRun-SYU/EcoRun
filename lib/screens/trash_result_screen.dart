import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/trash_model.dart';
import '../services/api_service.dart';

class TrashResultScreen extends StatefulWidget {
  final TrashAnalyzeResult result;
  final int runId;

  const TrashResultScreen({
    super.key,
    required this.result,
    required this.runId,
  });

  @override
  State<TrashResultScreen> createState() => _TrashResultScreenState();
}

class _TrashResultScreenState extends State<TrashResultScreen> {
  bool _saving = false;

  Future<void> _continueRun() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ApiService.instance.addTrashToRun(widget.runId, widget.result.totalCount);
    if (!mounted) return;
    Navigator.pop(context, widget.result.totalCount);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final tags = result.items
        .map((item) => '${item.trashType} x${item.count}')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: _saving
              ? null
              : () => Navigator.pop(context, 0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text('쓰레기 수거 인증',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            Text('AI가 자동 분석 후 EXP를 지급해요',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
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
                children: [
                  Row(
                    children: [
                      Text('EcoRun',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withAlpha(30),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 14, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text('인증 완료',
                                style: TextStyle(
                                    color: AppColors.primaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _settingRow(context, Icons.wifi_tethering_rounded,
                      '러닝 위치 공유', true),
                  const SizedBox(height: 8),
                  _settingRow(context, Icons.pause_circle_outline_rounded,
                      '자동 일시 중지', true),
                  const SizedBox(height: 8),
                  _settingRow(
                      context, Icons.volume_up_outlined, '음성 피드백', true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Trash tags
            Wrap(
              spacing: 8,
              children: tags
                  .map((t) => _trashTag(t, AppColors.primaryContainer))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('인증된 수거 목록',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer,
                    )),
            const SizedBox(height: 12),
            ...result.items.map((item) => _collectItem(context, item)),
            const SizedBox(height: 16),
            // EXP banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '총 ${result.totalCount}개 수거 완료',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                  Text('+${result.totalExp}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  const Text('EXP',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _continueRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_forward_rounded),
                label: const Text('러닝 계속하기',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(
      BuildContext context, IconData icon, String label, bool value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium)),
        Icon(
          value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
          color: value ? AppColors.primaryContainer : AppColors.outline,
          size: 32,
        ),
      ],
    );
  }

  Widget _trashTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _collectItem(BuildContext context, TrashAnalyzeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon,
                color: AppColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.trashType,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text('수량 ${item.count}개 · 개당 ${item.expEach} EXP',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text('+${item.totalExp}',
              style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ],
      ),
    );
  }
}
