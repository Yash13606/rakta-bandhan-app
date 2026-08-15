import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedBloodGroup;

  String? _nameError;
  String? _whatsappError;
  String? _bloodGroupError;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Name is required' : null;
      _whatsappError = whatsapp.isEmpty ? 'WhatsApp number is required' : null;
      _bloodGroupError = _selectedBloodGroup == null ? 'Please select a blood group' : null;
    });

    if (name.isNotEmpty && whatsapp.isNotEmpty && _selectedBloodGroup != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Complete registration',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Provide details to complete your profile.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              // Name Field
              Text(
                'Full name',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
              if (_nameError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _nameError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 24),

              // WhatsApp Field
              Text(
                'WhatsApp number',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (_) {
                  if (_whatsappError != null) setState(() => _whatsappError = null);
                },
                decoration: const InputDecoration(
                  hintText: 'Enter WhatsApp number',
                ),
              ),
              if (_whatsappError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _whatsappError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 24),

              // Location Field
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Search city or area',
                  suffixIcon: Icon(
                    LucideIcons.mapPin,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Blood Group Grid
              Text(
                'Blood group',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              
              // 4x2 Grid of blood groups using columns of rows (custom GridView style)
              Column(
                children: [
                  Row(
                    children: List.generate(4, (index) {
                      final group = _bloodGroups[index];
                      final isSelected = _selectedBloodGroup == group;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < 3 ? 8.0 : 0.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBloodGroup = group;
                                _bloodGroupError = null;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                group,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? AppColors.whiteTextOnPrimary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (index) {
                      final group = _bloodGroups[index + 4];
                      final isSelected = _selectedBloodGroup == group;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < 3 ? 8.0 : 0.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBloodGroup = group;
                                _bloodGroupError = null;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                group,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? AppColors.whiteTextOnPrimary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              if (_bloodGroupError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _bloodGroupError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 40),

              // Complete Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('Complete registration'),
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
