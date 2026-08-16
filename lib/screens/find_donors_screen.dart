import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import 'donor_details_screen.dart';

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _position;

  @override
  void initState() {
    super.initState();
    Backend.instance.currentPosition().then((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        locationLabel: 'Requested via Find Donors',
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
          'Find Donors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Static Map Placeholder Area
          Positioned.fill(
            child: Container(
              color: AppColors.mapBase,
              child: CustomPaint(
                painter: MapBasePainter(),
              ),
            ),
          ),

          // 2. Custom Map Pins (decorative placement — no paid maps/geocoding
          // API wired up; real donor data drives the list below instead)
          Positioned(
            top: 150,
            left: 120,
            child: _buildMapPin(context, 'O+'),
          ),
          Positioned(
            top: 250,
            right: 80,
            child: _buildMapPin(context, 'A-'),
          ),

          // 3. Floating Search Bar
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 4. Bottom Sheet (Muted overlay design)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(20, 26, 26, 26),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Center Drag Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Section Label
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                    child: Text(
                      'Nearby donors',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),

                  // Scrollable Donor List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Backend.instance.availableDonorsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        final myUid = Backend.instance.currentUser?.uid;
                        final docs = snapshot.data!.docs.where((d) => d.id != myUid).toList();
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No available donors nearby yet.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          );
                        }
                        final donors = docs.map((d) => _donorCardData(d)).toList()
                          ..sort((a, b) =>
                              (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: donors.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildDonorCard(context, donors[index]),
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

  Widget _buildMapPin(BuildContext context, String bloodGroup) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(77, 140, 31, 43),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.droplet,
            color: AppColors.whiteTextOnPrimary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            bloodGroup,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.whiteTextOnPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(BuildContext context, Map<String, dynamic> donor) {
    final bool isAvailable = donor['isAvailable'] as bool;
    final bool isVerified = donor['isVerified'] as bool;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Initials Avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLightTint,
                ),
                alignment: Alignment.center,
                child: Text(
                  donor['initials'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(width: 12),

              // Donor details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          donor['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: 8),
                        // Blood Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            donor['bloodGroup'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          // Verified badge
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.statusAvailableBg,
                            ),
                            child: const Icon(
                              LucideIcons.check,
                              color: AppColors.statusAvailableText,
                              size: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          donor['distance'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Availability Status Dot
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
                          isAvailable ? 'Available' : 'Unavailable',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // View & Request Actions
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
                child: OutlinedButton(
                  onPressed: () => _sendRequestTo(donor),
                  child: const Text('Request'),
                ),
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
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();
    final km = (_position != null && lat != null && lng != null)
        ? distanceKm(_position!.latitude, _position!.longitude, lat, lng)
        : 0.0;

    return {
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

class MapBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.mapGridRoads
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Drawing road network lines across the base
    final path1 = Path();
    path1.moveTo(0, size.height * 0.15);
    path1.lineTo(size.width, size.height * 0.55);
    canvas.drawPath(path1, paintGrid);

    final path2 = Path();
    path2.moveTo(size.width * 0.25, 0);
    path2.lineTo(size.width * 0.45, size.height);
    canvas.drawPath(path2, paintGrid);

    final path3 = Path();
    path3.moveTo(0, size.height * 0.7);
    path3.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.6,
      size.width,
      size.height * 0.75,
    );
    canvas.drawPath(path3, paintGrid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
