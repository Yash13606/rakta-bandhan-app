import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/notifications_service.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _service = MockNotificationsService();
  int _retryToken = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimaryWarm),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<NotificationsFeed>(
                  key: ValueKey(_retryToken),
                  stream: _service.watchNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: _errorState(() => setState(() => _retryToken++)),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    final feed = snapshot.data!;
                    if (!feed.enabled) return _disabledState();
                    if (feed.items.isEmpty) return _emptyState();
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: feed.items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _notificationCard(feed.items[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disabledState() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.warmAmberBg, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.bellOff, size: 17, color: AppColors.warmAmberText),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications are off', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A4A08))),
                    SizedBox(height: 2),
                    Text('Turn them on to hear about nearby requests instantly.', style: TextStyle(fontSize: 12, color: Color(0xFF8A7350))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification permissions coming soon')),
            ),
            child: const Text('Enable notifications'),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.cardBorderWarm)),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.bell, size: 20, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text('No notifications yet.', style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _errorState(VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.wifiOff, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text("Couldn't load notifications", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
          const SizedBox(height: 4),
          const Text('Check your connection and try again.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _notificationCard(AppNotification n) {
    final (bg, color, icon) = switch (n.kind) {
      NotificationKind.match => (AppColors.warmGreenBg, AppColors.warmGreenText, LucideIcons.checkCircle),
      NotificationKind.request => (AppColors.primaryLightTint, AppColors.primary, LucideIcons.droplet),
      NotificationKind.cancellation => (AppColors.primaryLightTint, AppColors.primary, LucideIcons.x),
      NotificationKind.expiration => (AppColors.warmAmberBg, AppColors.warmAmberText, LucideIcons.hourglass),
      NotificationKind.donationConfirmed => (AppColors.primaryLightTint, AppColors.primary, LucideIcons.droplet),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorderWarm),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowCard, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
                const SizedBox(height: 3),
                Text(n.body, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 6),
                Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.textMutedWarm)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
