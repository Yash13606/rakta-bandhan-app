import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class DonorDetailsScreen extends StatelessWidget {
  final String name;
  final String initials;
  final String bloodGroup;
  final bool isVerified;
  final String distance;
  final bool isAvailable;
  final String city;

  const DonorDetailsScreen({
    super.key,
    required this.name,
    required this.initials,
    required this.bloodGroup,
    required this.isVerified,
    required this.distance,
    required this.isAvailable,
    this.city = 'Thiruvananthapuram',
  });

  String _translateBloodGroup(String bg) {
    switch (bg) {
      case 'O+': return 'O positive';
      case 'O-': return 'O negative';
      case 'A+': return 'A positive';
      case 'A-': return 'A negative';
      case 'B+': return 'B positive';
      case 'B-': return 'B negative';
      case 'AB+': return 'AB positive';
      case 'AB-': return 'AB negative';
      default: return bg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Donor Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Centered Circular Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLightTint,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 28,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Centered Name
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),

              // 3. Blood Badge Centered
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bloodGroup,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Badges (Verified & Availability Status together)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isVerified) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusAvailableBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.check,
                            color: AppColors.statusAvailableText,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: AppColors.statusAvailableText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.statusAvailableBg
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAvailable
                                ? AppColors.statusAvailableText
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Available now' : 'Unavailable',
                          style: TextStyle(
                            color: isAvailable
                                ? AppColors.statusAvailableText
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Distance and City
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$distance · $city',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Divider line
              const Divider(
                color: AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 24),

              // 7. Info Block Detail list
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Blood group',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          _translateBloodGroup(bloodGroup),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Availability',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          isAvailable ? 'Available now' : 'Unavailable',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isAvailable
                                    ? AppColors.statusAvailableText
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 8. Primary "Request donor" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Blood request sent to $name.'),
                      ),
                    );
                  },
                  child: const Text('Request donor'),
                ),
              ),
              const SizedBox(height: 12),

              // 9. Call and WhatsApp side-by-side secondary buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling $name...'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.phone, size: 14),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening WhatsApp chat with $name...'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.messageSquare, size: 14),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
