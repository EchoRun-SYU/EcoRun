import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import '../app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keyAutoPause = 'settings_auto_pause';
  static const _keyVoiceFeedback = 'settings_voice_feedback';
  static const _keyScreenLock = 'settings_screen_lock';

  bool _autoPause = true;
  bool _voiceFeedback = true;
  bool _screenLock = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoPause = prefs.getBool(_keyAutoPause) ?? true;
      _voiceFeedback = prefs.getBool(_keyVoiceFeedback) ?? true;
      _screenLock = prefs.getBool(_keyScreenLock) ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('설정', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sectionLabel(context, '하드웨어 접근', '앱 권한 관리'),
            const SizedBox(height: 12),
            _permissionItem(context, Icons.map_outlined, AppColors.primaryContainer, '지도', '러닝 경로 및 지도 표시'),
            _permissionItem(context, Icons.camera_alt_outlined, AppColors.secondaryContainer, '카메라', '쓰레기 사진 촬영 및 인식'),
            _permissionItem(context, Icons.gps_fixed_rounded, AppColors.primaryContainer, 'GPS', '실시간 위치 추적'),
            const SizedBox(height: 24),
            _sectionLabel(context, '앱 설정', '러닝 동작 설정'),
            const SizedBox(height: 12),
            _toggleItem(
              context,
              Icons.pause_circle_outline_rounded,
              AppColors.primaryContainer,
              '자동 일시 중지',
              '정지 감지 시 러닝 자동 대기',
              _autoPause,
              (v) {
                setState(() => _autoPause = v);
                _saveSetting(_keyAutoPause, v);
              },
            ),
            _toggleItem(
              context,
              Icons.volume_up_outlined,
              AppColors.primaryContainer,
              '음성 피드백',
              '러닝 진행 상황 음성 안내',
              _voiceFeedback,
              (v) {
                setState(() => _voiceFeedback = v);
                _saveSetting(_keyVoiceFeedback, v);
              },
            ),
            _toggleItem(
              context,
              Icons.lock_outline_rounded,
              AppColors.outline,
              '화면 잠금',
              '러닝 중 화면 잠금 방지',
              _screenLock,
              (v) {
                setState(() => _screenLock = v);
                _saveSetting(_keyScreenLock, v);
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'EcoRun v1.0.0',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }

  Widget _permissionItem(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: AppColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.outline),
        onTap: () => AppSettings.openAppSettings(),
      ),
    );
  }

  Widget _toggleItem(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: AppColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryContainer,
          activeTrackColor: AppColors.primaryContainer.withAlpha(120),
        ),
      ),
    );
  }
}
