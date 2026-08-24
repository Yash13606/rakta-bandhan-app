import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'match_contact_screen.dart';

enum AcceptOutcome { success, claimed, blocked }

/// Result of a real Backend.instance.acceptRequest() call (success/claimed),
/// or of the frontend's own single-active-match guard (blocked) — see
/// RequestDetailScreen. No new backend logic here, just presenting the
/// outcome already determined there.
class AcceptResultScreen extends StatelessWidget {
  final AcceptOutcome outcome;
  final String? activeRequestId;

  const AcceptResultScreen({super.key, required this.outcome, this.activeRequestId});

  void _goHome(BuildContext context) => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (outcome == AcceptOutcome.success) ..._success(context),
              if (outcome == AcceptOutcome.claimed) ..._claimed(context),
              if (outcome == AcceptOutcome.blocked) ..._blocked(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _success(BuildContext context) => [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: AppColors.warmGreenBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.checkCircle, size: 28, color: AppColors.warmGreenText),
        ),
        const SizedBox(height: 16),
        const Text("You've accepted this request", textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm)),
        const SizedBox(height: 8),
        const Text(
          'Contact details are ready below. Please reach out and confirm a time.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MatchContactScreen(requestId: activeRequestId!)),
            ),
            child: const Text('View contact details'),
          ),
        ),
      ];

  List<Widget> _claimed(BuildContext context) => [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.xCircle, size: 28, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text('Already accepted', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm)),
        const SizedBox(height: 8),
        const Text(
          "Someone else got there first. Thank you for being ready to help — there'll be another request soon.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _goHome(context), child: const Text('Back to home'))),
      ];

  List<Widget> _blocked(BuildContext context) => [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: AppColors.warmAmberBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.alertTriangle, size: 28, color: AppColors.warmAmberText),
        ),
        const SizedBox(height: 16),
        const Text('You already have an active match', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm)),
        const SizedBox(height: 8),
        const Text(
          'You can only hold one active match at a time. Finish or cancel your current match before accepting a new request.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MatchContactScreen(requestId: activeRequestId!)),
            ),
            child: const Text('View my active match'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _goHome(context), child: const Text('Back to home'))),
      ];
}
