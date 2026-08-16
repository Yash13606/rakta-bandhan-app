import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';

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
          'Donor Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Centered Circular Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLightTint,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.initials,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 28,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Centered Name
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),

              // 3. Blood Badge Centered
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.bloodGroup,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Badges (Verified & Availability Status together)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isVerified) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusAvailableBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.check,
                            color: AppColors.statusAvailableText,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: AppColors.statusAvailableText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isAvailable
                          ? AppColors.statusAvailableBg
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isAvailable
                                ? AppColors.statusAvailableText
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isAvailable ? 'Available now' : 'Unavailable',
                          style: TextStyle(
                            color: widget.isAvailable
                                ? AppColors.statusAvailableText
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Distance and City
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.distance} · ${widget.city}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Divider line
              const Divider(
                color: AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 24),

              // 7. Info Block Detail list
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Blood group',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        _translateBloodGroup(widget.bloodGroup),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Availability',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        widget.isAvailable ? 'Available now' : 'Unavailable',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.isAvailable
                                  ? AppColors.statusAvailableText
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 8. Primary "Request donor" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendRequest,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteTextOnPrimary),
                        )
                      : const Text('Request donor'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact details unlock once ${widget.name.split(' ').first} accepts your request.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
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
