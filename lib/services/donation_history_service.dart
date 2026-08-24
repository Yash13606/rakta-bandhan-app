import 'package:flutter/foundation.dart';

@immutable
class DonationRecord {
  final String hospital;
  final String date;
  final String bloodGroup;

  const DonationRecord({required this.hospital, required this.date, required this.bloodGroup});
}

/// Past-donations list. `Backend` only exposes a count today
/// (`myDonationCount`) — no query for the underlying fulfilled requests
/// exists yet. This mock stands in until the backend developer adds that
/// query behind the same interface.
abstract class DonationHistoryService {
  Future<List<DonationRecord>> fetchHistory();
}

class MockDonationHistoryService implements DonationHistoryService {
  @override
  Future<List<DonationRecord>> fetchHistory() async => const [
        DonationRecord(hospital: 'Fortis Hospital, Cunningham Rd', date: '14 May 2026', bloodGroup: 'O+'),
        DonationRecord(hospital: "St. John's Medical College", date: '2 Feb 2026', bloodGroup: 'O+'),
        DonationRecord(hospital: 'Apollo Hospital, Bannerghatta', date: '9 Nov 2025', bloodGroup: 'O+'),
      ];
}
