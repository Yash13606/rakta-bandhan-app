import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';

class VerifyingScreen extends StatelessWidget {
  const VerifyingScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.statusPendingBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.shieldCheck, size: 28, color: AppColors.statusPendingText),
              ),
              const SizedBox(height: 14),
              Text(
                'Verification pending',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 8),
              Text(
                "We're reviewing your details — usually within a few hours. You can browse and receive requests in the meantime; donating unlocks once verified.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                      fontSize: 13.5,
                    ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continue(context),
                  child: const Text('Continue to Rakta Bandhan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
