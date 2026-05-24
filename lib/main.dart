import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'services/api_service.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoRunApp());
}

class EcoRunApp extends StatelessWidget {
  const EcoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _StartupScreen(),
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  @override
  void initState() {
    super.initState();
    // 첫 프레임이 렌더링된 후에 세션 복원을 시작해야 검은 화면 방지
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    final hasSession = await AppState.instance.restoreSession();
    if (!mounted) return;
    if (!hasSession) {
      _navigate(const LoginScreen());
      return;
    }
    try {
      final user = await ApiService.instance.getMe();
      final level = await ApiService.instance.getMyLevel();
      AppState.instance.setUser(user);
      AppState.instance.setLevel(level);
      if (mounted) _navigate(const MainScaffold());
    } catch (_) {
      await AppState.instance.logout();
      if (mounted) _navigate(const LoginScreen());
    }
  }

  void _navigate(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F9F5),
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
    );
  }
}
