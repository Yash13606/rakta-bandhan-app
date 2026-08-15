import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'find_donors_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Greeting Header
              Text(
                'Good morning, Ashi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to make a difference?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),

              // 2. Emergency Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.droplet,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need blood?',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find compatible donors near you.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FindDonorsScreen(),
                          ),
                        );
                      },
                      child: const Text('Find blood donors'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Nearby Requests Section
              Text(
                'Nearby requests',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Blood Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'O+',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Urgent Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusUrgentBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Urgent',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.statusUrgentText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                        const Spacer(),
                        // Distance Text
                        Text(
                          '2.4 km away',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location details
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'City Hospital, Central Square',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Outlined View request Button
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to request details view
                      },
                      child: const Text('View request'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Your Impact Section
              Text(
                'Your impact',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              // Side by side stats inside muted background block
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAE4), // muted background fill, no border
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '2',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Donations',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '6',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lives helped',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
