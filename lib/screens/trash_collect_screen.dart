import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'trash_result_screen.dart';

class TrashCollectScreen extends StatefulWidget {
  final int runId;

  const TrashCollectScreen({super.key, required this.runId});

  @override
  State<TrashCollectScreen> createState() => _TrashCollectScreenState();
}

class _TrashCollectScreenState extends State<TrashCollectScreen> {
  bool _analyzing = false;
  final _picker = ImagePicker();

  Future<void> _analyzeFromCamera() => _pickAndAnalyze(ImageSource.camera);
  Future<void> _analyzeFromGallery() => _pickAndAnalyze(ImageSource.gallery);

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_analyzing) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _analyzing = true);
    try {
      final bytes = await picked.readAsBytes();
      final result = await ApiService.instance
          .analyzeTrash(bytes, mimeType: picked.mimeType);
      if (!mounted) return;
      final count = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => TrashResultScreen(
            result: result,
            runId: widget.runId,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, count ?? 0);
    } catch (_) {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: _analyzing ? null : () => Navigator.pop(context, 0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('쓰레기 수거 인증',
                style: Theme.of(context).textTheme.bodyLarge),
            Text('AI가 자동 분석 후 EXP를 지급해요',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 11)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.outlineVariant,
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.eco_rounded,
                              color: AppColors.secondaryContainer, size: 36),
                        ),
                        const SizedBox(height: 20),
                        Text('수거한 쓰레기 사진이 필요해요',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('사진을 찍거나 갤러리에서 선택하세요',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Camera button
                GestureDetector(
                  onTap: _analyzing ? null : _analyzeFromCamera,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _analyzing
                          ? AppColors.primaryContainer.withAlpha(160)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('카메라로 찍기',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                            Text('지금 바로 사진 촬영',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Gallery button
                GestureDetector(
                  onTap: _analyzing ? null : _analyzeFromGallery,
                  child: Container(
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
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.photo_library_outlined,
                              color: AppColors.onSurfaceVariant, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('갤러리에서 선택',
                                style:
                                    Theme.of(context).textTheme.bodyLarge),
                            Text('저장된 사진 불러오기',
                                style:
                                    Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // AI 분석 중 오버레이
          if (_analyzing)
            Container(
              color: Colors.black.withAlpha(100),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'AI가 쓰레기를 분석하고 있어요...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
