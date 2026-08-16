import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// Recipient blood group -> donor groups that can give to it.
const bloodCompatibility = <String, List<String>>{
  'A+': ['A+', 'A-', 'O+', 'O-'],
  'A-': ['A-', 'O-'],
  'B+': ['B+', 'B-', 'O+', 'O-'],
  'B-': ['B-', 'O-'],
  'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
  'AB-': ['A-', 'B-', 'AB-', 'O-'],
  'O+': ['O+', 'O-'],
  'O-': ['O-'],
};

const donorCooldownDays = 90;
const requestExpiryHours = 6;

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Standard interleaved-bits geohash encoder. Stored on donor/request docs
/// for schema parity with the Cloud Functions upgrade path (geofire-common
/// on the server side); the live app itself never runs a geohash range
/// query — dataset is demo-scale, so donor/request lists are just filtered
/// and sorted by Haversine distance client-side.
String encodeGeohash(double lat, double lng, {int precision = 9}) {
  double latMin = -90, latMax = 90, lngMin = -180, lngMax = 180;
  final buffer = StringBuffer();
  var isEven = true;
  var bit = 0;
  var ch = 0;

  while (buffer.length < precision) {
    if (isEven) {
      final mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        ch |= (1 << (4 - bit));
        lngMin = mid;
      } else {
        lngMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        ch |= (1 << (4 - bit));
        latMin = mid;
      } else {
        latMax = mid;
      }
    }
    isEven = !isEven;
    if (bit < 4) {
      bit++;
    } else {
      buffer.write(_base32[ch]);
      bit = 0;
      ch = 0;
    }
  }
  return buffer.toString();
}

double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLng = (lng2 - lng1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
  return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
}

/// Thrown when a donor tries to accept a request someone else already claimed.
class RequestAlreadyClaimedException implements Exception {
  const RequestAlreadyClaimedException();
  @override
  String toString() => 'Someone else already accepted this request.';
}

/// Firebase data layer for Rakta Bandhan.
///
/// No Cloud Functions run behind this (Spark plan, see
/// backend/BACKEND_REFERENCE.md) — matching, accept-locking, contact
/// reveal, and the 90-day cooldown are all done here, client-side, backed
/// by Firestore transactions and security rules for the parts that need to
/// stay honest (see backend/firestore.rules for the matching validation).
class Backend {
  Backend._();
  static final Backend instance = Backend._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const _fakeAuthPassword = 'RaktaBandhan#2026Demo';
  static const _fakeAuthEmailDomain = 'phone.raktabandhan.local';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();
  String get _uid => _auth.currentUser!.uid;

  String _emailForPhone(String phone) => 'p$phone@$_fakeAuthEmailDomain';

  /// Fake OTP: any correctly-formatted 6-digit code is accepted client-side
  /// (see otp_screen.dart) — this just signs in/up a stable account keyed
  /// by phone number, so the same phone always lands on the same profile.
  Future<User> verifyFakeOtp(String phone) async {
    final email = _emailForPhone(phone);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _fakeAuthPassword,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: _fakeAuthPassword,
        );
        return cred.user!;
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<DocumentSnapshot<Map<String, dynamic>>> myDonorDoc() =>
      _db.collection('donors').doc(_uid).get();

  Stream<DocumentSnapshot<Map<String, dynamic>>> myDonorDocStream() =>
      _db.collection('donors').doc(_uid).snapshots();

  Future<bool> hasProfile() async => (await myDonorDoc()).exists;

  Future<void> registerDonor({
    required String name,
    required String phone,
    required String bloodGroup,
    required double lat,
    required double lng,
  }) async {
    final geohash = encodeGeohash(lat, lng);
    final now = FieldValue.serverTimestamp();

    final batch = _db.batch();
    batch.set(_db.collection('donors').doc(_uid), {
      'name': name,
      'phone': phone,
      'blood_group': bloodGroup,
      'geohash': geohash,
      'lat': lat,
      'lng': lng,
      'is_available': true,
      'is_verified': true,
      'created_at': now,
    });
    batch.set(_db.collection('donors_public').doc(_uid), {
      'name': name,
      'blood_group': bloodGroup,
      'geohash': geohash,
      'lat': lat,
      'lng': lng,
      'is_available': true,
      'is_verified': true,
      'updated_at': now,
    });
    await batch.commit();
  }

  Future<void> setAvailability(bool available) async {
    final batch = _db.batch();
    batch.update(_db.collection('donors').doc(_uid), {'is_available': available});
    batch.update(_db.collection('donors_public').doc(_uid), {
      'is_available': available,
      'updated_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Client-side stand-in for scheduledReactivation.js — call on profile load.
  Future<void> maybeReactivate() async {
    final snap = await myDonorDoc();
    if (!snap.exists) return;
    final data = snap.data()!;
    if (data['is_available'] == true) return;
    final reactivateAt = data['reactivation_scheduled_at'] as Timestamp?;
    if (reactivateAt == null || reactivateAt.toDate().isAfter(DateTime.now())) return;
    await setAvailability(true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> availableDonorsStream() =>
      _db.collection('donors_public').where('is_available', isEqualTo: true).snapshots();

  /// Open requests, newest first. Blood-group compatibility is filtered
  /// client-side (see note on encodeGeohash above) to avoid needing an
  /// extra composite index for a demo-scale dataset.
  Stream<QuerySnapshot<Map<String, dynamic>>> openRequestsStream() => _db
      .collection('requests')
      .where('status', isEqualTo: 'open')
      .orderBy('created_at', descending: true)
      .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> myRequestsStream() => _db
      .collection('requests')
      .where('requester_uid', isEqualTo: _uid)
      .orderBy('created_at', descending: true)
      .snapshots();

  List<String> compatibleRecipientGroups(String donorBloodGroup) => bloodCompatibility.entries
      .where((e) => e.value.contains(donorBloodGroup))
      .map((e) => e.key)
      .toList();

  Future<String> createRequest({
    required String bloodGroup,
    required int unitsNeeded,
    required String urgency,
    required double lat,
    required double lng,
    required String locationLabel,
  }) async {
    final geohash = encodeGeohash(lat, lng);
    final ref = await _db.collection('requests').add({
      'requester_uid': _uid,
      'blood_group': bloodGroup,
      'units_needed': unitsNeeded,
      'urgency': urgency,
      'location_label': locationLabel,
      'geohash': geohash,
      'lat': lat,
      'lng': lng,
      'status': 'open',
      'created_at': FieldValue.serverTimestamp(),
      'expires_at': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: requestExpiryHours)),
      ),
    });
    return ref.id;
  }

  Future<void> cancelRequest(String requestId) =>
      _db.collection('requests').doc(requestId).update({'status': 'cancelled'});

  /// Donor accepts an open request. A Firestore transaction still
  /// serializes concurrent accepts correctly even without a Cloud
  /// Function — only one donor's write wins; the loser gets this thrown.
  Future<void> acceptRequest(String requestId) async {
    final donorSnap = await myDonorDoc();
    if (!donorSnap.exists) throw StateError('No donor profile.');
    final donor = donorSnap.data()!;

    await _db.runTransaction((tx) async {
      final reqRef = _db.collection('requests').doc(requestId);
      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists || reqSnap.data()!['status'] != 'open') {
        throw const RequestAlreadyClaimedException();
      }
      tx.update(reqRef, {
        'status': 'matched',
        'matched_donor_id': _uid,
        'matched_donor_name': donor['name'],
        'matched_donor_phone': donor['phone'],
        'matched_at': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Matched donor self-reports the donation done and starts their own
  /// 90-day cooldown (admin confirmation is the Blaze-upgrade path).
  Future<void> markFulfilled(String requestId) async {
    final reactivateAt = DateTime.now().add(const Duration(days: donorCooldownDays));

    final batch = _db.batch();
    batch.update(_db.collection('requests').doc(requestId), {
      'status': 'fulfilled',
      'fulfilled_at': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('donors').doc(_uid), {
      'last_donation_date': FieldValue.serverTimestamp(),
      'is_available': false,
      'reactivation_scheduled_at': Timestamp.fromDate(reactivateAt),
    });
    batch.update(_db.collection('donors_public').doc(_uid), {
      'is_available': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<int> myDonationCount() async {
    final snap = await _db
        .collection('requests')
        .where('matched_donor_id', isEqualTo: _uid)
        .where('status', isEqualTo: 'fulfilled')
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Falls back to Thiruvananthapuram (matches the existing UI's demo
  /// city) if the browser/device denies location — never blocks the flow.
  Future<Position> currentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallbackPosition();
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return _fallbackPosition();
    }
  }

  Position _fallbackPosition() => Position(
        latitude: 8.5241,
        longitude: 76.9366,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}
