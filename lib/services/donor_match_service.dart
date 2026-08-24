import 'package:flutter/foundation.dart';

@immutable
class DonorMatch {
  final String name;
  final String initials;
  final String bloodGroup;
  final String distance;

  const DonorMatch({required this.name, required this.initials, required this.bloodGroup, required this.distance});
}

/// Matched-donor identity for the mock matching ladder's "donor found"
/// outcome (see MatchingLadderService) — no real donor has actually
/// accepted anything yet. The backend developer replaces
/// MockDonorMatchService with a real matched-donor lookup behind this same
/// interface; DonorFoundScreen itself won't need to change.
abstract class DonorMatchService {
  Future<DonorMatch> fetchMatch(String requestId);
}

class MockDonorMatchService implements DonorMatchService {
  @override
  Future<DonorMatch> fetchMatch(String requestId) async {
    return const DonorMatch(name: 'Rohan Mehta', initials: 'RM', bloodGroup: 'O+', distance: '2.1 km away');
  }
}
