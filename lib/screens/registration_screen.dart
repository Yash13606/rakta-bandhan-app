import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  const RegistrationScreen({super.key, required this.phoneNumber});

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
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _addressSuggestions = [];
  double? _selectedLat;
  double? _selectedLng;
  bool _searchingAddress = false;
  Timer? _addressDebounce;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void initState() {
    super.initState();
    _whatsappController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _addressDebounce?.cancel();
    _nameController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onLocationChanged(String value) {
    _selectedLat = null;
    _selectedLng = null;
    _addressDebounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _addressSuggestions = []);
      return;
    }
    _addressDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searchingAddress = true);
      final results = await Backend.instance.searchAddress(value);
      if (!mounted) return;
      setState(() {
        _addressSuggestions = results;
        _searchingAddress = false;
      });
    });
  }

  void _pickAddress(Map<String, dynamic> suggestion) {
    setState(() {
      _locationController.text = suggestion['label'] as String;
      _selectedLat = suggestion['lat'] as double;
      _selectedLng = suggestion['lng'] as double;
      _addressSuggestions = [];
    });
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Name is required' : null;
      _whatsappError = whatsapp.isEmpty ? 'WhatsApp number is required' : null;
      _bloodGroupError = _selectedBloodGroup == null ? 'Please select a blood group' : null;
    });

    if (name.isEmpty || whatsapp.isEmpty || _selectedBloodGroup == null) return;

    setState(() => _isSubmitting = true);
    try {
      double lat, lng;
      if (_selectedLat != null && _selectedLng != null) {
        lat = _selectedLat!;
        lng = _selectedLng!;
      } else {
        final position = await Backend.instance.currentPosition();
        lat = position.latitude;
        lng = position.longitude;
      }
      await Backend.instance.registerDonor(
        name: name,
        phone: whatsapp,
        bloodGroup: _selectedBloodGroup!,
        lat: lat,
        lng: lng,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
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
                onChanged: _onLocationChanged,
                decoration: InputDecoration(
                  hintText: 'Search city or area',
                  suffixIcon: _searchingAddress
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(LucideIcons.mapPin),
                ),
              ),
              if (_addressSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final suggestion in _addressSuggestions)
                        ListTile(
                          dense: true,
                          leading: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                          title: Text(
                            suggestion['label'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _pickAddress(suggestion),
                        ),
                    ],
                  ),
                )
              else if (_selectedLat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Location pinned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.statusAvailableText,
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
                  onPressed: _isSubmitting ? null : _handleRegister,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteTextOnPrimary),
                        )
                      : const Text('Complete registration'),
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
