import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/donor_match_service.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/status_badge.dart';

/// Terminal screen of the mock matching ladder's "donor found" outcome.
/// The donor identity comes from DonorMatchService/MockDonorMatchService —
/// no real donor accepted anything (see MatchingScreen). The backend
/// developer swaps in a real matched-donor lookup behind that interface
/// without changing this screen.
class DonorFoundScreen extends StatelessWidget {
  final String requestId;
  final DonorMatchService _service = MockDonorMatchService();

  DonorFoundScreen({super.key, required this.requestId});

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _placeholderAction(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => _goHome(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DonorMatch>(
          future: _service.fetchMatch(requestId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            final donor = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: AppColors.warmGreenBg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.checkCircle, size: 24, color: AppColors.warmGreenText),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${donor.name.split(' ').first} accepted your request',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${donor.bloodGroup} · ${donor.distance} · verified donor',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AvatarBadge(initials: donor.initials, size: 44, fontSize: 15),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(donor.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      StatusBadge.bloodGroup(donor.bloodGroup),
                                      const SizedBox(width: 6),
                                      const Text('Available now', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _placeholderAction(context, 'Call'),
                                icon: const Icon(LucideIcons.phone, size: 14),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _placeholderAction(context, 'WhatsApp'),
                                icon: const Icon(LucideIcons.messageSquare, size: 14),
                                label: const Text('WhatsApp'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(onPressed: () => _goHome(context), child: const Text('Back to home')),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
