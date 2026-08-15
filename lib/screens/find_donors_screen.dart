import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'donor_details_screen.dart';

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _nearbyDonors = [
    {
      'initials': 'AG',
      'name': 'Ashi Gupta',
      'bloodGroup': 'O+',
      'isVerified': true,
      'distance': '1.2 km away',
      'isAvailable': true,
    },
    {
      'initials': 'RN',
      'name': 'Rahul Nair',
      'bloodGroup': 'A-',
      'isVerified': false,
      'distance': '1.8 km away',
      'isAvailable': true,
    },
    {
      'initials': 'SP',
      'name': 'Siddharth Patel',
      'bloodGroup': 'B+',
      'isVerified': true,
      'distance': '2.5 km away',
      'isAvailable': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // 2. Custom Map Pins
          // Pin 1: Ashi Gupta (O+)
          Positioned(
            top: 150,
            left: 120,
            child: _buildMapPin(context, 'O+'),
          ),
          // Pin 2: Rahul Nair (A-)
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
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _nearbyDonors.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final donor = _nearbyDonors[index];
                        return _buildDonorCard(context, donor);
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Blood request sent to ${donor['name']}.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
