import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../services/matching_ladder_service.dart';
import '../theme/app_colors.dart';
import '../widgets/blood_group_droplet.dart';
import '../widgets/ring_field.dart';
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

class _MatchingScreenState extends State<MatchingScreen> with SingleTickerProviderStateMixin {
  final _service = MockMatchingLadderService();
  StreamSubscription<MatchLadderState>? _sub;
  MatchLadderState? _state;
  bool _cancelling = false;
  bool _navigated = false;
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..repeat();
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
    _sweep.dispose();
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
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Positioned.fill(
                              child: RingField(scale: 1.0, referenceWidth: 390, color: Color(0xFFFBE6E8), outerOpacity: 0.16, middleOpacity: 0.26, innerOpacity: 0, strokeWidth: 1),
                            ),
                            AnimatedBuilder(
                              animation: _sweep,
                              builder: (context, child) => Transform.rotate(
                                angle: _sweep.value * 2 * math.pi,
                                child: child,
                              ),
                              child: Container(
                                width: 152,
                                height: 152,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(colors: [Color(0x66E9BFC4), Colors.transparent], stops: [0, 0.4]),
                                ),
                              ),
                            ),
                            ..._donorDots(state),
                            BloodGroupDroplet(label: widget.bloodGroup, size: 60, filled: true, color: AppColors.primary, textColor: const Color(0xFFFBE6E8), fontSize: 20, serif: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'SEARCHING · ${state?.stage.radiusLabel ?? '5 km'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.3, color: Color(0xFFE0A8AF)),
                      ),
                      const SizedBox(height: 10),
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

  /// Abstract "reached donors" dots — count driven by the real
  /// `notifiedCount` from the mock ladder service. Deliberately anonymous
  /// (no initials/names): the matching ladder never exposes real donor
  /// identities mid-search, so showing named avatars here would fabricate
  /// people. Brightest/largest = nearest, fading outward.
  List<Widget> _donorDots(MatchLadderState? state) {
    final notified = state?.notifiedCount ?? 0;
    const positions = [
      (dx: -72.0, dy: -84.0, size: 44.0, opacity: 0.95),
      (dx: 44.0, dy: -96.0, size: 38.0, opacity: 0.8),
      (dx: -96.0, dy: 44.0, size: 30.0, opacity: 0.65),
      (dx: 76.0, dy: 56.0, size: 26.0, opacity: 0.5),
    ];
    // At least one dot as soon as anyone's been notified, scaling up from
    // there — honest (still driven by the real count), but doesn't leave
    // the field looking empty the moment the ladder starts.
    final dotCount = notified <= 0 ? 0 : (1 + notified / 5).ceil().clamp(0, positions.length);
    return [
      for (var i = 0; i < dotCount; i++)
        Positioned(
          left: 110 + positions[i].dx,
          top: 110 + positions[i].dy,
          child: Opacity(
            opacity: positions[i].opacity,
            child: Container(
              width: positions[i].size,
              height: positions[i].size,
              decoration: const BoxDecoration(color: Color(0xFFFBE6E8), shape: BoxShape.circle),
            ),
          ),
        ),
    ];
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
