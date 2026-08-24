import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/state_card.dart';
import '../widgets/status_badge.dart';
import 'donor_details_screen.dart';

enum _MapPermissionState { checking, prompt, granted, denied }

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _position;
  _MapPermissionState _permissionState = _MapPermissionState.checking;

  List<Map<String, dynamic>> _suggestions = [];
  String? _searchedLabel;
  bool _searching = false;
  Timer? _debounce;

  String _bloodGroupFilter = 'All';
  String? _highlightedDonorId;
  int _retryToken = 0;

  static const _bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    setState(() => _permissionState = _MapPermissionState.checking);
    final permission = await Geolocator.checkPermission();
    final granted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    if (!mounted) return;
    if (granted) {
      _permissionState = _MapPermissionState.granted;
      _loadPosition();
    } else {
      setState(() => _permissionState = _MapPermissionState.prompt);
    }
  }

  Future<void> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    if (!mounted) return;
    final granted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    setState(() => _permissionState = granted ? _MapPermissionState.granted : _MapPermissionState.denied);
    if (granted) _loadPosition();
  }

  Future<void> _loadPosition() async {
    final p = await Backend.instance.currentPosition();
    if (mounted) setState(() => _position = p);
  }

  void _onSearchChanged(String value) {
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

  void _pickLocation(Map<String, dynamic> suggestion) {
    setState(() {
      _searchController.text = suggestion['label'] as String;
      _searchedLabel = suggestion['label'] as String;
      _position = Position(
        latitude: suggestion['lat'] as double,
        longitude: suggestion['lng'] as double,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      _suggestions = [];
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchedLabel = null;
      _suggestions = [];
    });
    _loadPosition();
  }

  Future<void> _sendRequestTo(Map<String, dynamic> donor) async {
    final bloodGroup = donor['bloodGroup'] as String;
    try {
      final pos = _position ?? await Backend.instance.currentPosition();
      await Backend.instance.createRequest(
        bloodGroup: bloodGroup,
        unitsNeeded: 1,
        urgency: 'urgent',
        lat: pos.latitude,
        lng: pos.longitude,
        locationLabel: _searchedLabel ?? 'Requested via Find Donors',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$bloodGroup blood request sent — visible to nearby donors.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapBase,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: AppColors.mapBase, child: CustomPaint(painter: _MapBasePainter())),
          ),

          if (_permissionState == _MapPermissionState.granted && _position != null)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              key: ValueKey(_retryToken),
              stream: Backend.instance.availableDonorsStream(),
              builder: (context, snapshot) {
                final myUid = Backend.instance.currentUser?.uid;
                final donors = (snapshot.data?.docs ?? [])
                    .where((d) => d.id != myUid)
                    .map(_donorCardData)
                    .where((d) => _bloodGroupFilter == 'All' || d['bloodGroup'] == _bloodGroupFilter)
                    .toList()
                  ..sort((a, b) => (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
                final pinDonors = donors.take(2).toList();
                const positions = [
                  {'top': 148.0, 'left': 108.0},
                  {'top': 258.0, 'right': 68.0},
                ];
                return Stack(
                  children: [
                    for (var i = 0; i < pinDonors.length; i++)
                      Positioned(
                        top: positions[i]['top'] as double,
                        left: positions[i]['left'],
                        right: positions[i]['right'],
                        child: _buildMapPin(pinDonors[i]),
                      ),
                  ],
                );
              },
            ),

          Positioned(
            top: 200,
            left: 165,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
            ),
          ),
          Positioned(
            top: 226,
            left: 191,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _floatingCircleButton(icon: LucideIcons.arrowLeft, onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 8),
                      Expanded(child: _searchBar()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilterChipRow(
                    activeBg: AppColors.textPrimaryWarm,
                    chips: [
                      for (final group in _bloodGroups)
                        FilterChipItem(label: group, active: _bloodGroupFilter == group, onTap: () => setState(() => _bloodGroupFilter = group)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_permissionState == _MapPermissionState.checking) const _MapLoadingOverlay(message: 'Checking location access…'),
          if (_permissionState == _MapPermissionState.prompt)
            _MapOverlay(
              secondaryLabel: 'Not now',
              onSecondary: () => setState(() {
                _permissionState = _MapPermissionState.granted;
                _loadPosition();
              }),
              child: StateCard.permission(
                title: 'Allow location access',
                message: 'We use your location to find compatible donors and requests nearby.',
                actionLabel: 'Allow',
                onAction: _requestPermission,
              ),
            ),
          if (_permissionState == _MapPermissionState.denied)
            _MapOverlay(
              child: StateCard(
                icon: LucideIcons.alertTriangle,
                iconBackground: AppColors.warmAmberBg,
                iconColor: AppColors.warmAmberText,
                title: 'Location access denied',
                message: "Enable location for Rakta Bandhan in your phone's settings to find nearby donors.",
                actionLabel: 'Open settings',
                onAction: () => Geolocator.openAppSettings(),
              ),
            ),
          if (_permissionState == _MapPermissionState.granted && _position == null) const _MapLoadingOverlay(message: 'Finding donors near you…'),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                boxShadow: [BoxShadow(color: AppColors.shadowCard.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.cardBorderWarm, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  if (_permissionState != _MapPermissionState.granted || _position == null)
                    const Expanded(
                      child: Center(child: Text('Allow location access to see nearby donors.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                    )
                  else
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        key: ValueKey(_retryToken),
                        stream: Backend.instance.availableDonorsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: StateCard.error(
                                title: "Couldn't load donors",
                                message: 'Check your connection and try again.',
                                onRetry: () => setState(() => _retryToken++),
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          }
                          final myUid = Backend.instance.currentUser?.uid;
                          final donors = snapshot.data!.docs
                              .where((d) => d.id != myUid)
                              .map(_donorCardData)
                              .where((d) => _bloodGroupFilter == 'All' || d['bloodGroup'] == _bloodGroupFilter)
                              .toList()
                            ..sort((a, b) => (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                                child: Row(
                                  children: [
                                    const Text('Nearby donors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
                                    const SizedBox(width: 6),
                                    Text('· ${donors.length} within range', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: donors.isEmpty
                                    ? Center(
                                        child: StateCard.empty(
                                          icon: LucideIcons.mapPin,
                                          title: 'No available donors nearby yet. Try expanding your search radius.',
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        itemCount: donors.length,
                                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) => _buildDonorCard(donors[index]),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorderWarm),
          boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimaryWarm),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.cardBorderWarm),
        boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search location',
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.textSecondary),
              suffixIcon: _searching
                  ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                  : (_searchedLabel != null
                      ? IconButton(icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary), onPressed: _clearSearch)
                      : null),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const Divider(height: 1),
            for (final suggestion in _suggestions)
              ListTile(
                dense: true,
                leading: const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondary),
                title: Text(suggestion['label'] as String, style: const TextStyle(fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _pickLocation(suggestion),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapPin(Map<String, dynamic> donor) {
    final isHighlighted = _highlightedDonorId == donor['id'];
    return GestureDetector(
      onTap: () => setState(() => _highlightedDonorId = donor['id'] as String),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.gradientMarkerStart, AppColors.gradientMarkerEnd]),
          borderRadius: BorderRadius.circular(20),
          border: isHighlighted ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [BoxShadow(color: AppColors.shadowHero, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.droplet, color: AppColors.whiteTextOnPrimary, size: 12),
            const SizedBox(width: 4),
            Text(donor['bloodGroup'] as String, style: const TextStyle(color: AppColors.whiteTextOnPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(Map<String, dynamic> donor) {
    final bool isAvailable = donor['isAvailable'] as bool;
    final bool isVerified = donor['isVerified'] as bool;
    final isHighlighted = _highlightedDonorId == donor['id'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isHighlighted ? AppColors.primary : AppColors.cardBorderWarm, width: isHighlighted ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLightTint),
                alignment: Alignment.center,
                child: Text(donor['initials'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(donor['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        StatusBadge(label: donor['bloodGroup'] as String, background: AppColors.primaryLightTint, textColor: AppColors.primary, fontSize: 11),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.warmGreenBg),
                            child: const Icon(LucideIcons.check, color: AppColors.warmGreenText, size: 10),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(donor['distance'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textMuted)),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isAvailable ? AppColors.warmGreenText : AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        Text(isAvailable ? 'Available' : 'Unavailable', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorDetailsScreen(
                          name: donor['name'] as String,
                          initials: donor['initials'] as String,
                          bloodGroup: donor['bloodGroup'] as String,
                          isVerified: donor['isVerified'] as bool,
                          distance: donor['distance'] as String,
                          isAvailable: donor['isAvailable'] as bool,
                        ),
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(onPressed: () => _sendRequestTo(donor), child: const Text('Request')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _donorCardData(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final name = data['name'] as String? ?? 'Donor';
    final initials = name.trim().isEmpty ? '?' : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();
    final km = (_position != null && lat != null && lng != null) ? distanceKm(_position!.latitude, _position!.longitude, lat, lng) : 0.0;

    return {
      'id': doc.id,
      'name': name,
      'initials': initials,
      'bloodGroup': data['blood_group'] as String? ?? '',
      'isVerified': data['is_verified'] as bool? ?? false,
      'isAvailable': data['is_available'] as bool? ?? false,
      'distance': '${km.toStringAsFixed(1)} km away',
      'distanceKm': km,
    };
  }
}

class _MapLoadingOverlay extends StatelessWidget {
  final String message;

  const _MapLoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.warmPageBackground.withValues(alpha: 0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapOverlay extends StatelessWidget {
  final Widget child;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _MapOverlay({required this.child, this.secondaryLabel, this.onSecondary});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.warmPageBackground.withValues(alpha: 0.98),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              if (secondaryLabel != null) ...[
                const SizedBox(height: 4),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.mapGridRoads
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.55);
    canvas.drawPath(path1, paintGrid);

    final path2 = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(path2, paintGrid);

    final path3 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.6, size.width, size.height * 0.75);
    canvas.drawPath(path3, paintGrid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
