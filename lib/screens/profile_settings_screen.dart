import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  static const _keyGender = 'profile_gender';
  static const _keyBirthYear = 'profile_birth_year';
  static const _keyHeight = 'profile_height';
  static const _keyWeight = 'profile_weight';

  late final TextEditingController _nicknameController;
  late final TextEditingController _birthYearController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String? _gender;
  bool _saving = false;
  bool _saved = false;
  String? _nicknameError;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: AppState.instance.currentUser?.nickname ?? '');
    _birthYearController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _loadLocalSettings();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _birthYearController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _gender = prefs.getString(_keyGender);
      final by = prefs.getInt(_keyBirthYear);
      if (by != null) _birthYearController.text = by.toString();
      final h = prefs.getDouble(_keyHeight);
      if (h != null) _heightController.text = h.toStringAsFixed(0);
      final w = prefs.getDouble(_keyWeight);
      if (w != null) _weightController.text = w.toStringAsFixed(0);
    });
  }

  bool _validate() {
    final nick = _nicknameController.text.trim();
    if (nick.isEmpty) {
      setState(() => _nicknameError = '닉네임을 입력해주세요');
      return false;
    }
    if (nick.length > 12) {
      setState(() => _nicknameError = '닉네임은 12자 이하로 입력해주세요');
      return false;
    }
    setState(() => _nicknameError = null);
    return true;
  }

  Future<void> _save() async {
    if (!_validate() || _saving) return;
    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_gender != null) await prefs.setString(_keyGender, _gender!);

      final by = int.tryParse(_birthYearController.text);
      if (by != null) await prefs.setInt(_keyBirthYear, by);

      final h = double.tryParse(_heightController.text);
      if (h != null) await prefs.setDouble(_keyHeight, h);

      final w = double.tryParse(_weightController.text);
      if (w != null) await prefs.setDouble(_keyWeight, w);

      // 닉네임 API 업데이트 시도 (백엔드 미지원 시 조용히 무시)
      try {
        await ApiService.instance
            .updateProfile(nickname: _nicknameController.text.trim());
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했어요')),
      );
    }
  }

  double? get _bmi {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h == null || w == null || h <= 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  String get _bmiLabel {
    final b = _bmi;
    if (b == null) return '';
    if (b < 18.5) return '저체중';
    if (b < 23) return '정상';
    if (b < 25) return '과체중';
    return '비만';
  }

  Color get _bmiColor {
    final b = _bmi;
    if (b == null) return AppColors.primaryContainer;
    if (b < 18.5) return const Color(0xFF3B82F6);
    if (b < 23) return AppColors.primaryContainer;
    if (b < 25) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('프로필 설정',
            style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _saved ? '저장됨' : '저장',
              style: const TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                  fontSize: 15),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1, color: AppColors.outlineVariant.withAlpha(80)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 아바타 ────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.primary
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.person_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text('프로필 사진 변경',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── 기본 정보 ─────────────────────────────────────────
            _sectionTitle(context, '기본 정보'),
            _fieldCard(
              context,
              icon: Icons.person_outline_rounded,
              label: '닉네임',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: _nicknameController,
                    builder: (ctx, child) => TextField(
                      controller: _nicknameController,
                      maxLength: 12,
                      decoration: const InputDecoration(
                        hintText: '닉네임을 입력하세요',
                        border: InputBorder.none,
                        counterText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface),
                      onChanged: (_) =>
                          setState(() => _nicknameError = null),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (_nicknameError != null)
                        Text(_nicknameError!,
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 11)),
                      const Spacer(),
                      ListenableBuilder(
                        listenable: _nicknameController,
                        builder: (ctx2, child2) => Text(
                          '${_nicknameController.text.length}/12자',
                          style: const TextStyle(
                              color: AppColors.outline, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 신체 정보 ─────────────────────────────────────────
            _sectionTitle(context, '신체 정보'),
            Text('입력하면 칼로리 소모량을 더 정확하게 계산해요',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 12)),
            const SizedBox(height: 12),

            // 성별
            _genderSelector(),
            const SizedBox(height: 10),

            // 출생연도
            _fieldCard(
              context,
              icon: Icons.calendar_today_outlined,
              label: '출생연도',
              child: TextField(
                controller: _birthYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '예: ${DateTime.now().year - 25}',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface),
              ),
            ),
            const SizedBox(height: 10),

            // 키 + 몸무게
            Row(
              children: [
                Expanded(
                  child: _bodyMetricCard(
                    label: '키',
                    unit: 'cm',
                    hint: '170',
                    icon: Icons.height_rounded,
                    controller: _heightController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bodyMetricCard(
                    label: '몸무게',
                    unit: 'kg',
                    hint: '65',
                    icon: Icons.monitor_weight_outlined,
                    controller: _weightController,
                  ),
                ),
              ],
            ),

            // BMI 카드
            ListenableBuilder(
              listenable: Listenable.merge(
                  [_heightController, _weightController]),
              builder: (ctx, child) {
                final bmi = _bmi;
                if (bmi == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _bmiColor.withAlpha(30)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BMI 지수',
                                  style: TextStyle(
                                      color: AppColors.outline,
                                      fontSize: 11)),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: bmi.toStringAsFixed(1),
                                    style: TextStyle(
                                        color: _bmiColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  TextSpan(
                                    text: '  $_bmiLabel',
                                    style: TextStyle(
                                        color: _bmiColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('정상 범위',
                                  style: TextStyle(
                                      color: AppColors.outline,
                                      fontSize: 10)),
                              Text('18.5 ~ 22.9',
                                  style: TextStyle(
                                      color: AppColors.primaryContainer,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // ── 저장 버튼 ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved
                      ? const Color(0xFF059669)
                      : AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_saved) ...[
                            const Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _saved ? '저장 완료!' : '저장하기',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  Widget _fieldCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 17),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('성별',
              style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              _genderBtn('male', '남성'),
              const SizedBox(width: 8),
              _genderBtn('female', '여성'),
              const SizedBox(width: 8),
              _genderBtn('other', '기타'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderBtn(String value, String label) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppColors.primaryContainer.withAlpha(60),
                        blurRadius: 8)
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.outline,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyMetricCard({
    required String label,
    required String unit,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 15),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.outline,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Text(unit,
                  style: const TextStyle(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
