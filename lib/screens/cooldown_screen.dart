import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';

/// Real cooldown status — `donors/{uid}`'s `last_donation_date` and
/// `reactivation_scheduled_at` are already written by the existing
/// Backend.markFulfilled(); nothing here is mocked.
class CooldownScreen extends StatelessWidget {
  const CooldownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: Backend.instance.myDonorDocStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  final data = snapshot.data!.data() ?? {};
                  final reactivateAt = (data['reactivation_scheduled_at'] as Timestamp?)?.toDate();
                  final lastDonation = (data['last_donation_date'] as Timestamp?)?.toDate();
                  final isAvailable = data['is_available'] as bool? ?? true;

                  if (isAvailable || reactivateAt == null) {
                    return _eligibleState();
                  }

                  final remaining = reactivateAt.difference(DateTime.now());
                  final remainingDays = remaining.inDays < 0 ? 0 : remaining.inDays + 1;
                  final totalDays = donorCooldownDays;
                  final elapsedDays = lastDonation == null ? 0 : DateTime.now().difference(lastDonation).inDays;
                  final progress = (elapsedDays / totalDays).clamp(0.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.clock, size: 30, color: AppColors.statusPendingText),
                        const SizedBox(height: 12),
                        const Text('On cooldown', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text(
                          "Your body needs time to recover. You'll be marked available again automatically.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Text(
                                remainingDays == 1 ? '1 day' : '$remainingDays days',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.primary),
                              ),
                              const SizedBox(height: 4),
                              const Text("until you're eligible again", style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eligibleState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: AppColors.warmGreenBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.checkCircle, size: 24, color: AppColors.warmGreenText),
          ),
          const SizedBox(height: 16),
          const Text("You're eligible to donate again", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Your cooldown period is over. Turn your availability back on from Profile whenever you\'re ready.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
