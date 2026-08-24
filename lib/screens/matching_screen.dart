import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../services/matching_ladder_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cancel_confirm_screen.dart';
import 'donor_found_screen.dart';
import 'no_donor_found_screen.dart';

/// Visual matching-ladder screen. This is a frontend simulation of the
/// matching experience (MockMatchingLadderService), never the real backend
/// matching engine — the request document itself is real (created via
/// Backend.instance.createRequest), but no acceptance/matching is written
/// here. Whether the ladder ends in "donor found" or "no donor found" is
/// decided once, honestly, from a real snapshot of compatible available
/// donors — not a hardcoded flag or a user-facing toggle.
class MatchingScreen extends StatefulWidget {
  final String requestId;
  final String bloodGroup;
  final String urgency;

  const MatchingScreen({super.key, required this.requestId, required this.bloodGroup, required this.urgency});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final _service = MockMatchingLadderService();
  StreamSubscription<MatchLadderState>? _sub;
  MatchLadderState? _state;
  bool _cancelling = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final compatibleGroups = bloodCompatibility[widget.bloodGroup] ?? const <String>[];
    final donors = await Backend.instance.availableDonorsStream().first;
    final hasCompatibleDonor = donors.docs.any((d) => compatibleGroups.contains(d.data()['blood_group']));

    _sub = _service.watchLadder(urgency: widget.urgency, forceNoDonor: !hasCompatibleDonor).listen((state) {
      if (!mounted) return;
      setState(() => _state = state);
      if (state.outcome != MatchOutcome.pending) _handleOutcome(state.outcome);
    });
  }

  void _handleOutcome(MatchOutcome outcome) {
    if (_navigated) return;
    _navigated = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (outcome == MatchOutcome.donorFound) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DonorFoundScreen(requestId: widget.requestId)));
      } else {
        final escalated = _state?.stage == MatchStage.escalate;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NoDonorFoundScreen(requestId: widget.requestId, wasEscalated: escalated)),
        );
      }
    });
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    await _sub?.cancel();
    try {
      await Backend.instance.cancelRequest(widget.requestId);
    } catch (_) {
      // Already terminal server-side (matched/expired) — fine to proceed to
      // the cancel-confirmation screen either way from the requester's view.
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CancelConfirmScreen(requestId: widget.requestId)));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final visibleStages = state == null ? const [MatchStage.initial5] : [...state.completedStages, state.stage];

    return Scaffold(
      backgroundColor: AppColors.gradientMatchingStart,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.3, -1),
              end: Alignment(0.3, 1),
              colors: [AppColors.gradientMatchingStart, AppColors.gradientMatchingEnd],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 172,
                        height: 172,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.16)))),
                            Container(
                              margin: const EdgeInsets.all(24),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.26))),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [AppColors.gradientMarkerStart, AppColors.primary]),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              alignment: Alignment.center,
                              child: Text(state?.stage.radiusLabel ?? '5 km', style: AppTextStyles.display(fontSize: 14, color: AppColors.whiteTextOnPrimary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        state?.stage.headline ?? 'Notifying donors within 5 km…',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFF9F5), height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Runs automatically · ${state?.notifiedCount ?? 4} donors notified so far',
                        style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: [
                            for (var i = 0; i < visibleStages.length; i++)
                              _stageRow(visibleStages[i], state, showDivider: i < visibleStages.length - 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: TextButton(
                  onPressed: _cancelling ? null : _cancel,
                  child: Text(_cancelling ? 'Cancelling…' : 'Cancel this request', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.55))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageRow(MatchStage stage, MatchLadderState? state, {required bool showDivider}) {
    final isDone = state != null && state.completedStages.contains(stage);
    final isCurrent = state != null && state.stage == stage && !isDone;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))) : null),
      child: Row(
        children: [
          if (isDone)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: Color.fromRGBO(90, 180, 110, 0.2), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.check, size: 12, color: Color(0xFF7FCB8E)),
            )
          else if (isCurrent)
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEDA5AC)))
          else
            Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 2))),
          const SizedBox(width: 10),
          Text(stage.shortLabel, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}
