import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../services/donation_history_service.dart';
import '../theme/app_colors.dart';
import '../widgets/state_card.dart';

/// Total-donations count comes from the real Backend.instance
/// (myDonationCount) — the per-donation list itself uses
/// DonationHistoryService/MockDonationHistoryService since backend.dart
/// doesn't expose a query for individual fulfilled-request records yet.
class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final DonationHistoryService _service = MockDonationHistoryService();
  late final Future<(int, List<DonationRecord>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(int, List<DonationRecord>)> _load() async {
    final count = await Backend.instance.myDonationCount();
    final history = await _service.fetchHistory();
    return (count, history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Donation history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<(int, List<DonationRecord>)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: StateCard.error(title: "Couldn't load donation history", onRetry: () => setState(() => _future = _load())),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            final (count, history) = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.statBlockBackground, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(child: _statColumn('$count', 'Total donations')),
                        Container(width: 1, height: 36, color: AppColors.border),
                        Expanded(child: _statColumn('$count', 'Lives helped')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: StateCard.empty(icon: LucideIcons.history, title: "No donations recorded yet."),
                    )
                  else
                    Column(
                      children: [
                        for (final record in history) ...[
                          _historyCard(record),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _historyCard(DonationRecord record) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.hospital, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${record.date} · ${record.bloodGroup}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.statusAvailableBg, borderRadius: BorderRadius.circular(6)),
            child: const Text('Completed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.statusAvailableText)),
          ),
        ],
      ),
    );
  }
}
