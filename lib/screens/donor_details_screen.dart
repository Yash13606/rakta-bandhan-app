import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/gradient_hero_card.dart';
import '../widgets/loading_button.dart';

/// Pre-match donor discovery screen. Deliberately has no Call/WhatsApp
/// actions — per the prototype and the "unlock on accept" caption below,
/// contact details are only real once a request is accepted (see
/// MatchContactScreen). Showing them here would be fabricating access to
/// sensitive donor information the donor hasn't agreed to share yet.
class DonorDetailsScreen extends StatefulWidget {
  final String name;
  final String initials;
  final String bloodGroup;
  final bool isVerified;
  final String distance;
  final bool isAvailable;
  final String city;

  const DonorDetailsScreen({
    super.key,
    required this.name,
    required this.initials,
    required this.bloodGroup,
    required this.isVerified,
    required this.distance,
    required this.isAvailable,
    this.city = 'Thiruvananthapuram',
  });

  @override
  State<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends State<DonorDetailsScreen> {
  bool _isSending = false;

  Future<void> _sendRequest() async {
    setState(() => _isSending = true);
    try {
      final pos = await Backend.instance.currentPosition();
      await Backend.instance.createRequest(
        bloodGroup: widget.bloodGroup,
        unitsNeeded: 1,
        urgency: 'urgent',
        lat: pos.latitude,
        lng: pos.longitude,
        locationLabel: 'Requested via ${widget.name}\'s profile',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blood request sent — visible to nearby ${widget.bloodGroup} donors.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send request. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _translateBloodGroup(String bg) {
    switch (bg) {
      case 'O+': return 'O positive';
      case 'O-': return 'O negative';
      case 'A+': return 'A positive';
      case 'A-': return 'A negative';
      case 'B+': return 'B positive';
      case 'B-': return 'B negative';
      case 'AB+': return 'AB positive';
      case 'AB-': return 'AB negative';
      default: return bg;
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
        title: const Text('Donor profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeroCard(
                startColor: AppColors.gradientHeaderStart,
                endColor: AppColors.gradientHeaderEnd,
                gradientBegin: Alignment.topRight,
                gradientEnd: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                ringRight: -40,
                ringTop: -40,
                ringLeft: null,
                ringBottom: null,
                ringSize: 150,
                child: Column(
                  children: [
                    AvatarBadge(initials: widget.initials, size: 72, fontSize: 22, translucent: true),
                    const SizedBox(height: 12),
                    Text(widget.name, textAlign: TextAlign.center, style: AppTextStyles.display(fontSize: 20, color: const Color(0xFFFFF9F5))),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _translucentPill(widget.bloodGroup, bold: true),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 6),
                          _translucentPill('Verified', icon: LucideIcons.check),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(43, 20, 20, 0.1), blurRadius: 24, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('${widget.distance} · ${widget.city}', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.dividerWarm)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Blood group', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                            Text(_translateBloodGroup(widget.bloodGroup), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Availability', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                            Text(
                              widget.isAvailable ? 'Available now' : 'Unavailable',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: widget.isAvailable ? AppColors.warmGreenText : AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (widget.isAvailable)
                      LoadingButton(label: 'Request donor', isLoading: _isSending, onPressed: _sendRequest)
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: const Text('Currently unavailable to donate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isAvailable
                          ? 'Contact details unlock once ${widget.name.split(' ').first} accepts your request.'
                          : '${widget.name.split(' ').first} is on a donation cooldown and cannot be requested right now.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _translucentPill(String label, {bool bold = false, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: bold ? 11 : 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.whiteTextOnPrimary.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: AppColors.whiteTextOnPrimary),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: bold ? 12.5 : 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: AppColors.whiteTextOnPrimary)),
        ],
      ),
    );
  }
}
