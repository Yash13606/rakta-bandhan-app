import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import '../widgets/loading_button.dart';
import 'matching_screen.dart';

enum _LocationState { idle, checking, denied, error }

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  static const _urgencyOptions = [
    (id: 'normal', label: 'Normal', desc: 'Can wait a few hours', icon: LucideIcons.clock),
    (id: 'urgent', label: 'Urgent', desc: 'Needed within a few hours', icon: LucideIcons.alertTriangle),
    (id: 'critical', label: 'Critical', desc: 'Immediate — life-threatening', icon: LucideIcons.flame),
  ];

  String? _bloodGroup;
  int _units = 1;
  String _urgency = 'normal';
  final _locationController = TextEditingController();
  double? _selectedLat;
  double? _selectedLng;
  List<Map<String, dynamic>> _suggestions = [];
  bool _searching = false;
  Timer? _debounce;
  _LocationState _locationState = _LocationState.idle;

  bool _isSubmitting = false;
  String? _bloodGroupError;
  String? _locationError;

  @override
  void dispose() {
    _debounce?.cancel();
    _locationController.dispose();
    super.dispose();
  }

  void _onLocationChanged(String value) {
    _selectedLat = null;
    _selectedLng = null;
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final results = await Backend.instance.searchAddress(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  void _pickAddress(Map<String, dynamic> suggestion) {
    setState(() {
      _locationController.text = suggestion['label'] as String;
      _selectedLat = suggestion['lat'] as double;
      _selectedLng = suggestion['lng'] as double;
      _suggestions = [];
      _locationState = _LocationState.idle;
      _locationError = null;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locationState = _LocationState.checking);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _locationState = _LocationState.denied);
        return;
      }
      final position = await Backend.instance.currentPosition();
      if (!mounted) return;
      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
        _locationController.text = 'Current location';
        _locationState = _LocationState.idle;
        _locationError = null;
        _suggestions = [];
      });
    } on LocationServiceDisabledException {
      if (mounted) setState(() => _locationState = _LocationState.error);
    } catch (_) {
      if (mounted) setState(() => _locationState = _LocationState.error);
    }
  }

  Future<void> _handleSubmit() async {
    final location = _locationController.text.trim();
    setState(() {
      _bloodGroupError = _bloodGroup == null ? 'Please select a blood group' : null;
      _locationError = location.isEmpty ? 'Please enter or pick a location' : null;
    });
    if (_bloodGroup == null || location.isEmpty) return;

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
      final requestId = await Backend.instance.createRequest(
        bloodGroup: _bloodGroup!,
        unitsNeeded: _units,
        urgency: _urgency,
        lat: lat,
        lng: lng,
        locationLabel: location,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchingScreen(requestId: requestId, bloodGroup: _bloodGroup!, urgency: _urgency),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send request. Please try again.')),
      );
    }
  }

  String get _urgencyLabel => _urgencyOptions.firstWhere((u) => u.id == _urgency).label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Blood group needed'),
                    const SizedBox(height: 12),
                    _bloodGroupGrid(),
                    if (_bloodGroupError != null) ...[
                      const SizedBox(height: 8),
                      Text(_bloodGroupError!, style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Units needed'),
                        Row(
                          children: [
                            _stepperButton(LucideIcons.minus, () => setState(() => _units = _units > 1 ? _units - 1 : 1)),
                            SizedBox(
                              width: 28,
                              child: Text('$_units', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimaryWarm)),
                            ),
                            _stepperButton(LucideIcons.plus, () => setState(() => _units = _units < 10 ? _units + 1 : 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _sectionLabel('Urgency'),
                    const SizedBox(height: 10),
                    for (final option in _urgencyOptions) ...[
                      _urgencyRow(option),
                      if (option != _urgencyOptions.last) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Location'),
                    if (_locationState == _LocationState.checking) ...[
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('Checking location access…', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                    if (_locationState == _LocationState.denied) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.warmAmberBg, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertTriangle, size: 14, color: AppColors.warmAmberText),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Couldn't detect your location — enter it manually below.",
                                style: TextStyle(fontSize: 12, color: AppColors.warmAmberText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_locationState == _LocationState.error) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.statusUrgentBg, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.wifiOff, size: 14, color: AppColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Location lookup failed — check your connection.', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              onChanged: _onLocationChanged,
                              decoration: const InputDecoration(
                                hintText: 'Search city or area',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_searching)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    if (_suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final suggestion in _suggestions)
                              ListTile(
                                dense: true,
                                leading: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                                title: Text(suggestion['label'] as String, style: const TextStyle(fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () => _pickAddress(suggestion),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _useCurrentLocation,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin, size: 13, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('Use current location', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: 8),
                      Text(_locationError!, style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF3E2),
                  border: Border.all(color: AppColors.warmAmberBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.sparkle, size: 15, color: AppColors.warmAmberText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF7A5A26), height: 1.5),
                          children: [
                            TextSpan(text: _bloodGroup ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: ' · $_unitsLabel unit(s) · '),
                            TextSpan(text: _urgencyLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: ' · ${_locationController.text.isEmpty ? 'no location yet' : _locationController.text}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LoadingButton(label: 'Send request', isLoading: _isSubmitting, onPressed: _handleSubmit),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String get _unitsLabel => '$_units';

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorderWarm),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 4, height: 14, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: AppColors.warmPageBackground, border: Border.all(color: AppColors.cardBorderWarm), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Icon(icon, size: 13, color: AppColors.textPrimaryWarm),
      ),
    );
  }

  Widget _bloodGroupGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        for (final group in _bloodGroups)
          GestureDetector(
            onTap: () => setState(() {
              _bloodGroup = group;
              _bloodGroupError = null;
            }),
            child: Container(
              decoration: BoxDecoration(
                color: _bloodGroup == group ? AppColors.primary : AppColors.warmPageBackground,
                border: Border.all(color: _bloodGroup == group ? AppColors.primary : AppColors.cardBorderWarm),
                borderRadius: BorderRadius.circular(13),
                boxShadow: _bloodGroup == group ? [BoxShadow(color: AppColors.shadowButton, blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                group,
                style: TextStyle(
                  fontSize: _bloodGroup == group ? 15 : 14,
                  fontWeight: _bloodGroup == group ? FontWeight.w700 : FontWeight.w500,
                  color: _bloodGroup == group ? AppColors.whiteTextOnPrimary : AppColors.textPrimaryWarm,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _urgencyRow(({String id, String label, String desc, IconData icon}) option) {
    final selected = _urgency == option.id;
    return GestureDetector(
      onTap: () => setState(() => _urgency = option.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.warmPageBackground,
          border: selected ? null : Border.all(color: AppColors.cardBorderWarm),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? AppColors.whiteTextOnPrimary.withValues(alpha: 0.18) : Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(option.icon, size: 14, color: selected ? AppColors.whiteTextOnPrimary : AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: selected ? AppColors.whiteTextOnPrimary : AppColors.textPrimaryWarm),
                  ),
                  Text(
                    option.desc,
                    style: TextStyle(fontSize: 11, color: selected ? const Color(0xFFE9BFC4) : AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
