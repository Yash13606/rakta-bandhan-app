import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

enum ConnectivityState { offline, reconnecting, syncedOk, syncedFail }

/// Top-of-scaffold connectivity banner (offline/reconnecting/synced states)
/// from the prototype. Purely presentational — callers pass a fixed/mock
/// `state` for now; the backend dev wires this to real connectivity later.
class ConnectivityBanner extends StatelessWidget {
  final ConnectivityState state;

  const ConnectivityBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String message;
    var spinning = false;

    switch (state) {
      case ConnectivityState.offline:
        bg = AppColors.statBlockBackground;
        fg = AppColors.textSecondary;
        icon = LucideIcons.wifiOff;
        message = "You're offline — actions will send once reconnected";
      case ConnectivityState.reconnecting:
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPendingText;
        icon = LucideIcons.wifiOff;
        message = 'Reconnecting…';
        spinning = true;
      case ConnectivityState.syncedOk:
        bg = AppColors.statusAvailableBg;
        fg = AppColors.statusAvailableText;
        icon = LucideIcons.checkCircle;
        message = 'Back online — your last action was saved';
      case ConnectivityState.syncedFail:
        bg = AppColors.statusUrgentBg;
        fg = AppColors.statusUrgentText;
        icon = LucideIcons.alertTriangle;
        message = "Back online — your last action couldn't be saved. Please retry.";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinning
                ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                : Icon(icon, size: 14, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}
