import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_badge.dart';
import 'donation_confirm_screen.dart';

/// Shows the requester's contact info for a request this donor accepted.
/// The requester's name/phone aren't stored on the request doc itself
/// (backend.dart's createRequest() never writes them there) — but since
/// every requester is also a registered donor, their real name/phone are
/// read from their own `donors/{requester_uid}` doc. Real data, composed
/// from two existing reads; no schema change, no mock identity needed.
class MatchContactScreen extends StatefulWidget {
  final String requestId;

  const MatchContactScreen({super.key, required this.requestId});

  @override
  State<MatchContactScreen> createState() => _MatchContactScreenState();
}

class _MatchContactScreenState extends State<MatchContactScreen> {
  bool _markingDonated = false;

  void _placeholder(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — coming soon.')));
  }

  Future<void> _markDonated() async {
    setState(() => _markingDonated = true);
    try {
      await Backend.instance.markFulfilled(widget.requestId);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DonationConfirmScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _markingDonated = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update this request. Please try again.')));
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Matched', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get(),
          builder: (context, requestSnap) {
            if (!requestSnap.hasData) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            final request = requestSnap.data!.data();
            if (request == null) {
              return const Center(child: Text('Request not found.', style: TextStyle(color: AppColors.textSecondary)));
            }
            final requesterUid = request['requester_uid'] as String?;
            final bloodGroup = request['blood_group'] as String? ?? '';
            final units = request['units_needed'] ?? 1;
            final location = (request['location_label'] as String?)?.isNotEmpty == true ? request['location_label'] as String : 'the requester';

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: requesterUid == null
                  ? null
                  : FirebaseFirestore.instance.collection('donors').doc(requesterUid).get(),
              builder: (context, donorSnap) {
                final requesterData = donorSnap.data?.data() ?? {};
                final name = requesterData['name'] as String? ?? 'Requester';
                final phone = requesterData['phone'] as String? ?? '—';
                final initials = name.trim().isEmpty
                    ? '?'
                    : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            AvatarBadge(initials: initials, size: 56, fontSize: 19),
                            const SizedBox(height: 12),
                            Text('$name · Requester', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('$bloodGroup · $units unit(s) · $location', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: AppColors.warmPageBackground, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.phone, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _placeholder('Call'),
                                    icon: const Icon(LucideIcons.phone, size: 14),
                                    label: const Text('Call'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _placeholder('WhatsApp'),
                                    icon: const Icon(LucideIcons.messageSquare, size: 14),
                                    label: const Text('WhatsApp'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton(
                        onPressed: _markingDonated ? null : _markDonated,
                        child: _markingDonated
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Mark as donated'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
