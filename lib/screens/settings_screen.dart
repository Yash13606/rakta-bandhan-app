import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import 'admin_login_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showExactAddress = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logOutEverywhere() async {
    await Backend.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeading('Privacy'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                            child: Row(
                              children: [
                                const Expanded(child: Text('Show exact address to matched donors', style: TextStyle(fontSize: 14))),
                                Switch(
                                  value: _showExactAddress,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) => setState(() => _showExactAddress = val),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _showSnackBar('Preparing your data export...'),
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Download my data', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionHeading('Account'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _showSnackBar('Data deletion request submitted.'),
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Request data deletion', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                              ),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                            child: InkWell(
                              onTap: _logOutEverywhere,
                              child: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Log out of all devices', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionHeading('Admin (temporary)'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen())),
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 12),
                              Expanded(child: Text('Admin Console', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                              Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: 0.4),
      ),
    );
  }
}
