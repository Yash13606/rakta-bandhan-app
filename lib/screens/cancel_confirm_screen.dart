import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

class CancelConfirmScreen extends StatelessWidget {
  final String requestId;

  const CancelConfirmScreen({super.key, required this.requestId});

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
                width: 56,
                height: 56,
                decoration: const BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.xCircle, size: 24, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Request cancelled',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm),
              ),
              const SizedBox(height: 8),
              const Text(
                'Donors who were already notified will see this request marked as cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
