import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'main_scaffold.dart';

class NicknameSetupScreen extends StatefulWidget {
  final String idToken;
  final String suggestedNickname;

  const NicknameSetupScreen({
    super.key,
    required this.idToken,
    required this.suggestedNickname,
  });

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  late final TextEditingController _nicknameController;
  bool _loading = false;
  String? _errorMessage;

  static const int _minLength = 2;
  static const int _maxLength = 12;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: widget.suggestedNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.length < _minLength) return '닉네임은 최소 $_minLength자 이상이어야 합니다';
    if (trimmed.length > _maxLength) return '닉네임은 최대 $_maxLength자까지 입력 가능합니다';
    return null;
  }

  Future<void> _confirm() async {
    final nickname = _nicknameController.text.trim();
    final error = _validate(nickname);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[1] loginWithGoogleToken 호출');
      final result = await ApiService.instance
          .loginWithGoogleToken(widget.idToken, nickname: nickname);
      debugPrint('[2] 응답: $result');

      final token = result['token'] as String? ?? '';
      final userId = (result['userId'] as num?)?.toInt() ?? decodeUserIdFromJwt(token);
      debugPrint('[3] userId: $userId, token 길이: ${token.length}');

      await AppState.instance.setAuth(token, userId);
      debugPrint('[4] setAuth 완료');

      final user = await ApiService.instance.getMe();
      debugPrint('[5] getMe 완료: ${user.nickname}');

      final level = await ApiService.instance.getMyLevel();
      debugPrint('[6] getMyLevel 완료');

      AppState.instance.setUser(user);
      AppState.instance.setLevel(level);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } catch (e) {
      debugPrint('닉네임 설정 오류: $e');
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildNicknameField(),
                  const SizedBox(height: 32),
                  _buildConfirmButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (_loading)
              Container(
                color: Colors.black.withAlpha(100),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryContainer),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.badge_outlined,
              color: AppColors.primaryContainer, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          'EcoRun에서 사용할\n닉네임을 설정해주세요',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          '나중에 프로필에서 변경할 수 있어요',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '닉네임',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: _nicknameController,
          builder: (context, value, _) {
            return TextField(
              controller: _nicknameController,
              maxLength: _maxLength,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              decoration: InputDecoration(
                hintText: '닉네임을 입력하세요',
                errorText: _errorMessage,
                counterText: '${value.text.length}/$_maxLength',
                counterStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.outline,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline,
                size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '구글 계정 이름으로 자동 입력됐어요',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ValueListenableBuilder(
      valueListenable: _nicknameController,
      builder: (context, value, _) {
        final isValid = value.text.trim().length >= _minLength;
        return ElevatedButton(
          onPressed: (!_loading && isValid) ? _confirm : null,
          child: const Text('시작하기'),
        );
      },
    );
  }
}
