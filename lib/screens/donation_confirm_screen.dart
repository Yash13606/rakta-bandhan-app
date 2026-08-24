import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'cooldown_screen.dart';

class DonationConfirmScreen extends StatelessWidget {
  const DonationConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.warmGreenBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.droplet, size: 28, color: AppColors.warmGreenText),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for donating!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm),
              ),
              const SizedBox(height: 8),
              const Text(
                "You've just helped save a life. You're now on a 90-day cooldown before you can donate again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CooldownScreen())),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
