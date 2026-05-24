import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'home_screen.dart';
import 'run_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final _screens = const [
    HomeScreen(),
    RunScreen(),
    RankingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, '홈'),
              _navItem(1, Icons.directions_run_rounded, Icons.directions_run_outlined, '러닝'),
              _navItem(2, Icons.emoji_events_rounded, Icons.emoji_events_outlined, '랭킹'),
              _navItem(3, Icons.person_rounded, Icons.person_outline_rounded, '프로필'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryContainer.withAlpha(30) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isActive ? active : inactive,
                  color: isActive ? AppColors.primary : AppColors.outline,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
