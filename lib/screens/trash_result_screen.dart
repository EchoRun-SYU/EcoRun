import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/trash_model.dart';
import '../services/api_service.dart';

class TrashResultScreen extends StatefulWidget {
  final TrashAnalyzeResult result;
  final int runId;
  final Uint8List? imageBytes;

  const TrashResultScreen({
    super.key,
    required this.result,
    required this.runId,
    this.imageBytes,
  });

  @override
  State<TrashResultScreen> createState() => _TrashResultScreenState();
}

class _TrashResultScreenState extends State<TrashResultScreen> {
  bool _saving = false;

  Future<void> _continueRun() async {
    if (_saving) return;
    setState(() => _saving = true);
    final trashType = widget.result.items.isNotEmpty
        ? widget.result.items.first.trashType
        : 'OTHER';
    await ApiService.instance.addTrashToRun(
      widget.runId,
      widget.result.totalCount,
      trashType: trashType,
    );
    if (!mounted) return;
    Navigator.pop(context, widget.result.totalCount);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: _saving ? null : () => Navigator.pop(context, 0),
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
            // 인증 사진 오버레이 (사진이 있을 때)
            if (widget.imageBytes != null)
              _buildPhotoHero(widget.imageBytes!, result),
            // 인증된 수거 목록 헤더
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('인증된 수거 목록',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      )),
            ),
            ...result.items.map((item) => _collectItem(context, item)),
            const SizedBox(height: 16),
            // EXP 배너
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFB923C), AppColors.secondaryContainer],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryContainer.withAlpha(70),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const Text(' EXP',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 계속하기 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _continueRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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

  Widget _buildPhotoHero(Uint8List bytes, TrashAnalyzeResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              // 하단 그라디언트
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(140)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // EcoRun 워터마크
              const Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Icon(Icons.eco_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text('EcoRun',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
              ),
              // 인증 완료 뱃지
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(235),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('인증 완료',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                    ],
                  ),
                ),
              ),
              // 하단 수거 아이템 태그
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: result.items
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.trashType} ×${item.count}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
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
