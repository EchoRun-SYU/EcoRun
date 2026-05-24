import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app_theme.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'main_scaffold.dart';
import 'nickname_setup_screen.dart';

final _googleSignIn = GoogleSignIn(
  serverClientId:
      '841154792818-tksoljcs8unr95c5cbnao1ppfqgfu05p.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google idToken을 받지 못했습니다');

      final result = await ApiService.instance.loginWithGoogleToken(idToken);
      final isNewUser = result['isNewUser'] as bool? ?? true;

      if (!mounted) return;

      if (isNewUser) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NicknameSetupScreen(
              idToken: idToken,
              suggestedNickname: account.displayName ?? '',
            ),
          ),
        );
      } else {
        final token = result['token'] as String? ?? '';
        final userId = (result['userId'] as num?)?.toInt() ??
            decodeUserIdFromJwt(token);

        await AppState.instance.setAuth(token, userId);
        final user = await ApiService.instance.getMe();
        final level = await ApiService.instance.getMyLevel();
        AppState.instance.setUser(user);
        AppState.instance.setLevel(level);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.eco,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'EcoRun',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '달리면서 지구를 지켜요 🌎',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '현재 구글 소셜 로그인만 지원합니다.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _socialButton(
                    color: AppColors.surfaceLowest,
                    textColor: AppColors.onSurface,
                    icon: 'G',
                    label: '구글로 로그인',
                    hasBorder: true,
                    onTap: _signInWithGoogle,
                  ),
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

  Widget _socialButton({
    required Color color,
    required Color textColor,
    required String icon,
    required String label,
    bool hasBorder = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: color,
        shape: hasBorder
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: AppColors.outlineVariant),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: _loading ? null : onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
