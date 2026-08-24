import 'package:flutter/foundation.dart';

enum NotificationKind { request, match, cancellation, expiration, donationConfirmed }

@immutable
class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String time;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
  });
}

/// A snapshot of the notification feed: whether notifications are enabled
/// (OS permission / user preference) and the items to show when they are.
@immutable
class NotificationsFeed {
  final bool enabled;
  final List<AppNotification> items;

  const NotificationsFeed({required this.enabled, required this.items});
}

/// Notification feed. No FCM/backend collection exists yet, so this is a
/// local mock — the backend developer replaces MockNotificationsService with
/// a real FCM + Firestore implementation behind this same interface.
abstract class NotificationsService {
  Stream<NotificationsFeed> watchNotifications();
}

class MockNotificationsService implements NotificationsService {
  static const _fixtures = <AppNotification>[
    AppNotification(
      id: 'n1',
      kind: NotificationKind.match,
      title: 'Rohan accepted your request',
      body: 'O+ · 2 units · Sneha Hospital, Koramangala',
      time: '2 min ago',
    ),
    AppNotification(
      id: 'n2',
      kind: NotificationKind.request,
      title: 'New compatible request nearby',
      body: 'A- needed · 1.8 km away',
      time: '18 min ago',
    ),
    AppNotification(
      id: 'n3',
      kind: NotificationKind.donationConfirmed,
      title: 'Thanks for donating!',
      body: "You've helped save a life. 90-day cooldown started.",
      time: '1 day ago',
    ),
    AppNotification(
      id: 'n4',
      kind: NotificationKind.expiration,
      title: 'Request expired',
      body: 'No donor found in time for your AB- request.',
      time: '2 days ago',
    ),
    AppNotification(
      id: 'n5',
      kind: NotificationKind.cancellation,
      title: 'Request cancelled',
      body: 'Your B+ request was cancelled.',
      time: '3 days ago',
    ),
  ];

  @override
  Stream<NotificationsFeed> watchNotifications() =>
      Stream.value(const NotificationsFeed(enabled: true, items: _fixtures));
}
