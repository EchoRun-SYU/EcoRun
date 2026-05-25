import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'trash_result_screen.dart';

enum _CollectPhase { idle, previewing, scanning }

class TrashCollectScreen extends StatefulWidget {
  final int runId;

  const TrashCollectScreen({super.key, required this.runId});

  @override
  State<TrashCollectScreen> createState() => _TrashCollectScreenState();
}

class _TrashCollectScreenState extends State<TrashCollectScreen>
    with SingleTickerProviderStateMixin {
  _CollectPhase _phase = _CollectPhase.idle;
  Uint8List? _previewBytes;
  final _picker = ImagePicker();
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickAndPreview(ImageSource source) async {
    if (_phase == _CollectPhase.scanning) return;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _previewBytes = bytes;
      _phase = _CollectPhase.previewing;
    });
  }

  Future<void> _startAnalysis() async {
    if (_phase != _CollectPhase.previewing || _previewBytes == null) return;
    setState(() => _phase = _CollectPhase.scanning);
    _scanController.repeat();
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        _previewBytes!,
        minWidth: 1280,
        minHeight: 1280,
        quality: 80,
        format: CompressFormat.webp,
      );
      final result = await ApiService.instance
          .analyzeTrash(compressed, mimeType: 'image/webp');
      if (!mounted) return;
      _scanController.stop();
      final count = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => TrashResultScreen(
            result: result,
            runId: widget.runId,
            imageBytes: _previewBytes,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, count ?? 0);
    } catch (_) {
      if (mounted) {
        _scanController.stop();
        setState(() {
          _phase = _CollectPhase.idle;
          _previewBytes = null;
        });
      }
    }
  }

  void _retake() {
    setState(() {
      _phase = _CollectPhase.idle;
      _previewBytes = null;
    });
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
          onPressed: _phase == _CollectPhase.scanning
              ? null
              : () => Navigator.pop(context, 0),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: _phase == _CollectPhase.idle
            ? _buildIdleContent()
            : _buildImageContent(),
      ),
    );
  }

  Widget _buildIdleContent() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant),
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
                        ?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCameraButton(),
        const SizedBox(height: 12),
        _buildGalleryButton(),
      ],
    );
  }

  Widget _buildImageContent() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: _phase == _CollectPhase.scanning ? 0.5 : 1.0,
                      child: Image.memory(
                        _previewBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (_phase == _CollectPhase.scanning) ...[
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (_, child) {
                          final top = (_scanController.value *
                                  constraints.maxHeight)
                              .clamp(0.0, constraints.maxHeight - 3.0);
                          return Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primaryContainer,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryContainer
                                        .withAlpha(180),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(235),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'AI 분석 중...',
                            style: TextStyle(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_phase == _CollectPhase.previewing) ...[
          _buildStartAnalysisButton(),
          TextButton(
            onPressed: _retake,
            child: const Text('다시 찍기',
                style: TextStyle(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ] else ...[
          _buildBouncingDots(),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildStartAnalysisButton() {
    return GestureDetector(
      onTap: _startAnalysis,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFB923C), AppColors.secondaryContainer],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryContainer.withAlpha(75),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('AI 인증 시작',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Widget _buildBouncingDots() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = ((_scanController.value - i * 0.15) % 1.0 + 1.0) % 1.0;
            final bounce =
                phase < 0.3 ? phase / 0.3 : phase < 0.6 ? 1.0 - (phase - 0.3) / 0.3 : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -8 * bounce),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () => _pickAndPreview(ImageSource.camera),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('카메라로 찍기',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                Text('지금 바로 사진 촬영',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () => _pickAndPreview(ImageSource.gallery),
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
                    style: Theme.of(context).textTheme.bodyLarge),
                Text('저장된 사진 불러오기',
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
