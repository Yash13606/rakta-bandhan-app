import 'package:flutter/foundation.dart';

enum DonorVerificationStatus { pending, verified, banned }

class AdminDonorEntry {
  final String id;
  String name;
  String bloodGroup;
  String phone;
  DonorVerificationStatus status;
  bool available;
  final String location;
  final String joinedOn;

  AdminDonorEntry({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.phone,
    required this.status,
    required this.available,
    this.location = 'Koramangala, Bengaluru',
    this.joinedOn = '3 months ago',
  });
}

class AdminRequestEntry {
  final String id;
  final String bloodGroup;
  final String status; // open / matched / fulfilled / cancelled / expired
  final String urgency; // normal / urgent / critical
  final String location;
  final String time;
  final int units;
  final String distance;
  final String? matchedDonorName;

  const AdminRequestEntry({
    required this.id,
    required this.bloodGroup,
    required this.status,
    required this.urgency,
    required this.location,
    required this.time,
    required this.units,
    required this.distance,
    this.matchedDonorName,
  });

  String get statusLabel => switch (status) {
        'open' => 'Open',
        'matched' => 'Matched',
        'fulfilled' => 'Fulfilled',
        'cancelled' => 'Cancelled',
        'expired' => 'Expired',
        _ => status,
      };
}

class AdminHospitalEntry {
  final String id;
  String name;
  String address;

  AdminHospitalEntry({required this.id, required this.name, required this.address});
}

class AdminAuditEntry {
  final String actor;
  final String text;
  final String time;

  const AdminAuditEntry({required this.actor, required this.text, required this.time});
}

/// In-memory admin console data — visual/mobile-companion screens only, per
/// scope. No real admin auth or persistence. Every mutation (verify/ban/
/// toggle/broadcast/hospital CRUD) updates local state only and appends an
/// audit entry; the backend developer replaces this with real
/// Firestore-backed admin services and authorization later, behind the same
/// shape.
class AdminMockService extends ChangeNotifier {
  AdminMockService._();
  static final AdminMockService instance = AdminMockService._();

  final List<AdminDonorEntry> donors = [
    AdminDonorEntry(id: 'd1', name: 'Rohan Mehta', bloodGroup: 'O+', phone: '98765 43210', status: DonorVerificationStatus.pending, available: true),
    AdminDonorEntry(id: 'd2', name: 'Priya Nair', bloodGroup: 'A-', phone: '91234 56789', status: DonorVerificationStatus.verified, available: false),
    AdminDonorEntry(id: 'd3', name: 'Karthik Iyer', bloodGroup: 'B+', phone: '99887 66554', status: DonorVerificationStatus.verified, available: true),
    AdminDonorEntry(id: 'd4', name: 'Sana Sheikh', bloodGroup: 'AB+', phone: '90000 11122', status: DonorVerificationStatus.banned, available: false),
  ];

  final List<AdminRequestEntry> requests = const [
    AdminRequestEntry(id: 'r1', bloodGroup: 'O+', status: 'open', urgency: 'urgent', location: 'Sneha Hospital, Koramangala', time: '12 min ago', units: 2, distance: '2.4 km'),
    AdminRequestEntry(id: 'r2', bloodGroup: 'AB-', status: 'open', urgency: 'critical', location: 'Whitefield Diagnostics', time: '6 min ago', units: 1, distance: '9.1 km'),
    AdminRequestEntry(id: 'r3', bloodGroup: 'B+', status: 'matched', urgency: 'normal', location: 'Apollo Hospital, Bannerghatta', time: '1 hour ago', units: 1, distance: '4.0 km', matchedDonorName: 'Karthik Iyer'),
    AdminRequestEntry(id: 'r4', bloodGroup: 'A-', status: 'fulfilled', urgency: 'normal', location: "St. John's Medical College", time: '1 day ago', units: 2, distance: '5.6 km', matchedDonorName: 'Priya Nair'),
  ];

  final List<AdminHospitalEntry> hospitals = [
    AdminHospitalEntry(id: 'h1', name: 'Sneha Hospital', address: 'Koramangala, Bengaluru'),
    AdminHospitalEntry(id: 'h2', name: 'Apollo Hospital', address: 'Bannerghatta Rd, Bengaluru'),
  ];

  final List<AdminAuditEntry> auditLog = [
    const AdminAuditEntry(actor: 'Admin', text: 'Verified donor Priya Nair', time: '2 hours ago'),
    const AdminAuditEntry(actor: 'Admin', text: 'Banned donor Sana Sheikh — fraudulent profile reports', time: '1 day ago'),
  ];

  /// Fulfilment rate for each of the last 7 days (0.0–1.0) — feeds the
  /// dashboard's small bar chart. Mock/static, not hardcoded in a widget.
  final List<double> weeklyFulfilmentRates = const [0.60, 0.75, 0.55, 0.88, 0.70, 0.95, 1.00];

  void _log(String action) {
    auditLog.insert(0, AdminAuditEntry(actor: 'You', text: action, time: 'just now'));
  }

  void verifyDonor(String id) {
    donors.firstWhere((d) => d.id == id).status = DonorVerificationStatus.verified;
    _log('Verified donor ${donors.firstWhere((d) => d.id == id).name}');
    notifyListeners();
  }

  void banDonor(String id) {
    final donor = donors.firstWhere((d) => d.id == id);
    donor.status = DonorVerificationStatus.banned;
    _log('Banned donor ${donor.name}');
    notifyListeners();
  }

  void unbanDonor(String id) {
    final donor = donors.firstWhere((d) => d.id == id);
    donor.status = DonorVerificationStatus.verified;
    _log('Unbanned donor ${donor.name}');
    notifyListeners();
  }

  void toggleAvailability(String id) {
    final donor = donors.firstWhere((d) => d.id == id);
    donor.available = !donor.available;
    _log('${donor.available ? 'Marked available' : 'Marked unavailable'}: ${donor.name}');
    notifyListeners();
  }

  void addHospital(String name, String address) {
    hospitals.add(AdminHospitalEntry(id: 'h${DateTime.now().microsecondsSinceEpoch}', name: name, address: address));
    _log('Added hospital $name');
    notifyListeners();
  }

  void updateHospital(String id, String name, String address) {
    final hospital = hospitals.firstWhere((h) => h.id == id);
    hospital.name = name;
    hospital.address = address;
    _log('Updated hospital $name');
    notifyListeners();
  }

  void deleteHospital(String id) {
    final hospital = hospitals.firstWhere((h) => h.id == id);
    hospitals.removeWhere((h) => h.id == id);
    _log('Removed hospital ${hospital.name}');
    notifyListeners();
  }

  void sendBroadcast(String message, String audience) {
    if (message.trim().isEmpty) return;
    final truncated = message.length > 42 ? '${message.substring(0, 42)}…' : message;
    _log('Broadcast to $audience: "$truncated"');
    notifyListeners();
  }
}
