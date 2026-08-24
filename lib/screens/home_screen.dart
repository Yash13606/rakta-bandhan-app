import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/gradient_hero_card.dart';
import '../widgets/state_card.dart';
import '../widgets/status_badge.dart';
import 'create_request_screen.dart';
import 'find_donors_screen.dart';
import 'notifications_screen.dart';
import 'request_detail_screen.dart';

enum _RequestFilter { all, urgent }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _position;
  int _donationCount = 0;
  _RequestFilter _filter = _RequestFilter.all;

  @override
  void initState() {
    super.initState();
    Backend.instance.currentPosition().then((p) {
      if (mounted) setState(() => _position = p);
    });
    Backend.instance.myDonationCount().then((c) {
      if (mounted) setState(() => _donationCount = c);
    });
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: Backend.instance.myDonorDocStream(),
          builder: (context, donorSnap) {
            final donor = donorSnap.data?.data() ?? {};
            final name = donor['name'] as String? ?? '';
            final isVerified = donor['is_verified'] as bool? ?? false;
            final isAvailable = donor['is_available'] as bool? ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AvatarBadge(initials: name.isEmpty ? '?' : _initials(name)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                            ),
                            Text(
                              name.isEmpty ? 'Welcome' : name.split(' ').first,
                              style: AppTextStyles.display(fontSize: 23, color: AppColors.textPrimaryWarm),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.cardBorderWarm),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(LucideIcons.bell, size: 18, color: AppColors.textPrimaryWarm),
                              Positioned(
                                top: 6,
                                right: 7,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _pillBadge(
                        isVerified ? 'Verified' : 'Verification pending',
                        icon: isVerified ? LucideIcons.check : LucideIcons.clock,
                        bg: isVerified ? AppColors.warmGreenBg : AppColors.warmAmberBg,
                        border: isVerified ? AppColors.warmGreenBorder : AppColors.warmAmberBorder,
                        text: isVerified ? AppColors.warmGreenText : AppColors.warmAmberText,
                      ),
                      const SizedBox(width: 8),
                      _pillBadge(
                        isAvailable ? 'Available to donate' : 'Not available',
                        dot: isAvailable ? AppColors.warmGreenText : AppColors.textMuted,
                        bg: isAvailable ? AppColors.warmGreenBg : Colors.white,
                        border: isAvailable ? AppColors.warmGreenBorder : AppColors.cardBorderWarm,
                        text: isAvailable ? AppColors.warmGreenText : AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GradientHeroCard(
                    borderRadius: BorderRadius.circular(22),
                    shadowColor: AppColors.shadowHero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.whiteTextOnPrimary.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.droplet, size: 19, color: AppColors.whiteTextOnPrimary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Need blood, right now?', style: AppTextStyles.display(fontSize: 19, color: const Color(0xFFFFF9F5))),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "We'll alert compatible donors within 5 km instantly.",
                                    style: TextStyle(fontSize: 12.5, color: Color(0xFFE9BFC4), height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warmPageBackground,
                            foregroundColor: AppColors.gradientHeroEnd,
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRequestScreen()));
                          },
                          child: const Text('Create a blood request'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FindDonorsScreen()));
                      },
                      child: const Text('Or browse donors on the map', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _sectionLabel('Nearby requests', AppColors.primary),
                      const Spacer(),
                      FilterChipRow(
                        activeBg: AppColors.textPrimaryWarm,
                        chips: [
                          FilterChipItem(label: 'All', active: _filter == _RequestFilter.all, onTap: () => setState(() => _filter = _RequestFilter.all)),
                          FilterChipItem(label: 'Urgent', active: _filter == _RequestFilter.urgent, onTap: () => setState(() => _filter = _RequestFilter.urgent)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: Backend.instance.openRequestsStream(),
                    builder: (context, snapshot) {
                      final myUid = Backend.instance.currentUser?.uid;
                      final docs = (snapshot.data?.docs ?? [])
                          .where((d) => d.data()['requester_uid'] != myUid)
                          .where((d) => _filter == _RequestFilter.all || (d.data()['urgency'] as String? ?? 'normal') != 'normal')
                          .toList();

                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      if (docs.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.cardBorderWarm),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: StateCard.empty(title: "You're all caught up — no nearby requests right now."),
                        );
                      }

                      final request = docs.first.data();
                      final distance = _position == null
                          ? null
                          : distanceKm(
                              _position!.latitude,
                              _position!.longitude,
                              (request['lat'] as num).toDouble(),
                              (request['lng'] as num).toDouble(),
                            );
                      final urgency = request['urgency'] as String? ?? 'normal';
                      final isUrgent = urgency != 'normal';

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.cardBorderWarm),
                              boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 14, offset: const Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    StatusBadge.bloodGroup(request['blood_group'] as String? ?? ''),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (request['location_label'] as String?)?.isNotEmpty == true
                                                ? request['location_label'] as String
                                                : 'Blood request',
                                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            urgency == 'critical' ? 'Critical' : (isUrgent ? 'Urgent' : 'Requested recently'),
                                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.only(top: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(top: BorderSide(color: AppColors.dividerWarm)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 5),
                                      Text(
                                        distance == null ? '—' : '${distance.toStringAsFixed(1)} km away',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(LucideIcons.hourglass, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${request['units_needed'] ?? 1} units needed',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimaryWarm),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RequestDetailScreen(requestId: docs.first.id)),
                                    );
                                  },
                                  child: const Text('View request'),
                                ),
                              ],
                            ),
                          ),
                          if (isUrgent) UrgentRibbon(label: urgency == 'critical' ? 'CRITICAL' : 'URGENT'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  _sectionLabel('Your impact', const Color(0xFFB8863B)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: LucideIcons.droplet,
                          iconBg: AppColors.primaryLightTint,
                          iconColor: AppColors.primary,
                          value: '$_donationCount',
                          label: 'Donations made',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          icon: LucideIcons.sparkle,
                          iconBg: AppColors.warmAmberIconTint,
                          iconColor: AppColors.warmAmberText,
                          value: '$_donationCount',
                          label: 'Lives helped',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color accent) {
    return Row(
      children: [
        Container(width: 4, height: 14, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
      ],
    );
  }

  Widget _pillBadge(String label, {IconData? icon, Color? dot, required Color bg, required Color border, required Color text}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: bg == Colors.white ? AppColors.border : Colors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, size: 10, color: text),
            )
          else if (dot != null)
            Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 5), decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: text)),
        ],
      ),
    );
  }

  Widget _statCard({required IconData icon, required Color iconBg, required Color iconColor, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorderWarm),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.display(fontSize: 30, color: AppColors.textPrimaryWarm)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
