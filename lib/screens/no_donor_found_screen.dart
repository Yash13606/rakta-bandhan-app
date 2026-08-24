import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';
import 'cancel_confirm_screen.dart';

class NoDonorFoundScreen extends StatefulWidget {
  final String requestId;
  final bool wasEscalated;

  const NoDonorFoundScreen({super.key, required this.requestId, this.wasEscalated = false});

  @override
  State<NoDonorFoundScreen> createState() => _NoDonorFoundScreenState();
}

class _NoDonorFoundScreenState extends State<NoDonorFoundScreen> {
  bool _cancelling = false;

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    try {
      await Backend.instance.cancelRequest(widget.requestId);
    } catch (_) {
      // Already terminal (e.g. expired) server-side — fine either way.
    }
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CancelConfirmScreen(requestId: widget.requestId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.warmAmberBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.alertTriangle, size: 28, color: AppColors.warmAmberText),
              ),
              const SizedBox(height: 16),
              const Text(
                'No donor found within 15 km',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimaryWarm),
              ),
              const SizedBox(height: 8),
              Text(
                widget.wasEscalated
                    ? "We expanded your search but couldn't find a match yet. This critical request has been escalated to our admin team for manual broadcast."
                    : "We expanded your search but couldn't find a match yet. Keep the request open and we'll notify you the moment a compatible donor becomes available.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _goHome, child: const Text("Keep waiting — I'll be notified")),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _cancelling ? null : _cancel,
                child: Text(_cancelling ? 'Cancelling…' : 'Cancel this request', style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
