import 'dart:async';
import 'package:flutter/foundation.dart';

enum MatchStage { initial5, expanded15, retry15m, retry45m, escalate }

extension MatchStageCopy on MatchStage {
  String get radiusLabel => this == MatchStage.initial5 ? '5 km' : '15 km';

  String get shortLabel => switch (this) {
        MatchStage.initial5 => '5 km radius',
        MatchStage.expanded15 => '15 km radius',
        MatchStage.retry15m => 'Retry in 15 min',
        MatchStage.retry45m => 'Retry in 45 min',
        MatchStage.escalate => 'Escalated to admin team',
      };

  String get headline => switch (this) {
        MatchStage.initial5 => 'Notifying donors within 5 km…',
        MatchStage.expanded15 => 'No response yet — expanding to 15 km…',
        MatchStage.retry15m => 'Still searching — retrying in 15 minutes…',
        MatchStage.retry45m => 'Still searching — retrying in 45 minutes…',
        MatchStage.escalate => 'Escalating to the admin team for manual broadcast…',
      };
}

enum MatchOutcome { pending, donorFound, noDonorFound }

@immutable
class MatchLadderState {
  final MatchStage stage;
  final MatchOutcome outcome;
  final int notifiedCount;
  final List<MatchStage> completedStages;

  const MatchLadderState({
    required this.stage,
    required this.outcome,
    required this.notifiedCount,
    required this.completedStages,
  });
}

/// Drives the prototype's visual matching ladder
/// (5km → 15km → retry+15m → retry+45m → escalate → expired).
///
/// This is a frontend UI simulation only — never the real matching engine.
/// The backend developer will later implement this same interface backed by
/// real request state, and every screen that consumes it stays unchanged.
abstract class MatchingLadderService {
  Stream<MatchLadderState> watchLadder({required String urgency, bool forceNoDonor = false});
}

class MockMatchingLadderService implements MatchingLadderService {
  static const _stepDelay = Duration(milliseconds: 1100);

  @override
  Stream<MatchLadderState> watchLadder({required String urgency, bool forceNoDonor = false}) {
    late final StreamController<MatchLadderState> controller;
    Timer? timer;

    final critical = urgency == 'critical';
    final sequence = forceNoDonor
        ? (critical
            ? const [MatchStage.initial5, MatchStage.expanded15, MatchStage.retry15m, MatchStage.retry45m, MatchStage.escalate]
            : const [MatchStage.initial5, MatchStage.expanded15, MatchStage.retry15m, MatchStage.retry45m])
        : const [MatchStage.initial5, MatchStage.expanded15];

    var index = 0;
    final completed = <MatchStage>[];

    void emitStep() {
      if (index >= sequence.length) {
        controller.add(MatchLadderState(
          stage: sequence.last,
          outcome: forceNoDonor ? MatchOutcome.noDonorFound : MatchOutcome.donorFound,
          notifiedCount: 12 + index * 8,
          completedStages: List.unmodifiable(completed),
        ));
        controller.close();
        return;
      }
      final stage = sequence[index];
      controller.add(MatchLadderState(
        stage: stage,
        outcome: MatchOutcome.pending,
        notifiedCount: 4 + index * 8,
        completedStages: List.unmodifiable(completed),
      ));
      completed.add(stage);
      index++;
      timer = Timer(_stepDelay, emitStep);
    }

    controller = StreamController<MatchLadderState>(
      onListen: emitStep,
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }
}
