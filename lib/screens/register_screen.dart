import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/mock_api_service.dart';
import '../state/app_state.dart';
import 'main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreedToTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final api = MockApiService.instance;
      final user = await api.signup(
        _emailController.text,
        _passwordController.text,
        _nicknameController.text,
      );
      final level = await api.getMyLevel();
      AppState.instance.setUser(user);
      AppState.instance.setLevel(level);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'EcoRun에 오신 걸\n환영합니다 🌿',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '환경을 지키는 러닝을 시작해보세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              _label('닉네임'),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(hintText: '닉네임을 입력하세요'),
              ),
              const SizedBox(height: 16),
              _label('이메일'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: '이메일을 입력하세요'),
              ),
              const SizedBox(height: 16),
              _label('비밀번호'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 (8자 이상)'),
              ),
              const SizedBox(height: 16),
              _label('비밀번호 확인'),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호를 다시 입력하세요'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryContainer,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Text(
                    '서비스 이용약관에 동의합니다',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      '(필수)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '보기',
                    style: TextStyle(fontSize: 14, color: AppColors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (_agreedToTerms && !_loading) ? _register : null,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('회원가입 완료'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '이미 계정이 있으신가요? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      );
}
