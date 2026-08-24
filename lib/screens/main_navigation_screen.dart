import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RequestsScreen(),
    ProfileScreen(),
  ];

  static const _tabs = [
    (icon: LucideIcons.home, label: 'Home'),
    (icon: LucideIcons.clipboardList, label: 'Requests'),
    (icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 16, offset: const Offset(0, -6))],
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _tabButton(index: i)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required int index}) {
    final isActive = _currentIndex == index;
    final tab = _tabs[index];
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLightTint : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 18, color: isActive ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
