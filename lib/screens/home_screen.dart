import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import 'find_donors_screen.dart';
import 'requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _position;
  int _donationCount = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Greeting Header
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: Backend.instance.myDonorDocStream(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.data()?['name'] as String? ?? '';
                  final greeting = _greeting();
                  return Text(
                    name.isEmpty ? greeting : '$greeting, ${name.split(' ').first}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to make a difference?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),

              // 2. Emergency Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.droplet,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need blood?',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find compatible donors near you.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FindDonorsScreen(),
                          ),
                        );
                      },
                      child: const Text('Find blood donors'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Nearby Requests Section
              Text(
                'Nearby requests',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: Backend.instance.openRequestsStream(),
                builder: (context, snapshot) {
                  final myUid = Backend.instance.currentUser?.uid;
                  final docs = (snapshot.data?.docs ?? [])
                      .where((d) => d.data()['requester_uid'] != myUid)
                      .toList();

                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (docs.isEmpty) {
                    return _emptyCard('No open requests near you right now.');
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

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['blood_group'] as String? ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (urgency != 'normal')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.statusUrgentBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  urgency == 'critical' ? 'Critical' : 'Urgent',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.statusUrgentText,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            const Spacer(),
                            if (distance != null)
                              Text(
                                '${distance.toStringAsFixed(1)} km away',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (request['location_label'] as String?)?.isNotEmpty == true
                                    ? request['location_label'] as String
                                    : '${request['units_needed'] ?? 1} unit(s) needed',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RequestsScreen()),
                            );
                          },
                          child: const Text('View request'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 4. Your Impact Section
              Text(
                'Your impact',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: AppColors.statBlockBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(child: _statColumn(context, '$_donationCount', 'Donations')),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(child: _statColumn(context, '$_donationCount', 'Lives helped')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _emptyCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _statColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}
