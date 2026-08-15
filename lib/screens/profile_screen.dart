import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAvailable = true;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          'Profile',
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
                    'AG',
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
                'Ashi Gupta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),

              // 3. Blood Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              ),
              const SizedBox(height: 16),

              // 4. Badges (Verified & Availability Dot/Label together)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isAvailable
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
                            color: _isAvailable
                                ? AppColors.statusAvailableText
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAvailable ? 'Available now' : 'Unavailable',
                          style: TextStyle(
                            color: _isAvailable
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
              const SizedBox(height: 24),

              // 5. Divider
              const Divider(
                color: AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 16),

              // 6. Menu Rows
              _buildMenuRow(
                context,
                icon: LucideIcons.user,
                label: 'Personal information',
                onTap: () => _showSnackBar('Opening Personal information...'),
              ),
              _buildMenuRow(
                context,
                icon: LucideIcons.history,
                label: 'Donation history',
                onTap: () => _showSnackBar('Opening Donation history...'),
              ),
              _buildMenuRow(
                context,
                icon: LucideIcons.phone,
                label: 'Emergency contact',
                onTap: () => _showSnackBar('Opening Emergency contact...'),
              ),
              _buildMenuRow(
                context,
                icon: LucideIcons.settings,
                label: 'Settings',
                onTap: () => _showSnackBar('Opening Settings...'),
              ),

              const SizedBox(height: 8),
              // 7. Divider
              const Divider(
                color: AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 8),

              // 8. Availability Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.activity,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Availability',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryLightTint,
                      inactiveThumbColor: AppColors.textMuted,
                      inactiveTrackColor: AppColors.border,
                      onChanged: (val) {
                        setState(() {
                          _isAvailable = val;
                        });
                        _showSnackBar(
                          _isAvailable
                              ? 'You are now available for donation'
                              : 'You are now offline',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              // 9. Divider
              const Divider(
                color: AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 16),

              // 10. Log Out row
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.logOut,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Log out',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
