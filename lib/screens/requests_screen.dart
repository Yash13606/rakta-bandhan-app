import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/backend.dart';
import '../theme/app_colors.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _activeTab = 'Received';
  String? _myBloodGroup;

  @override
  void initState() {
    super.initState();
    Backend.instance.myDonorDoc().then((snap) {
      if (mounted) setState(() => _myBloodGroup = snap.data()?['blood_group'] as String?);
    });
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'open':
        return AppColors.statusUrgentBg;
      case 'matched':
        return AppColors.statusPendingBg;
      case 'fulfilled':
        return AppColors.statusAvailableBg;
      default:
        return AppColors.border;
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'open':
        return AppColors.statusUrgentText;
      case 'matched':
        return AppColors.statusPendingText;
      case 'fulfilled':
        return AppColors.statusAvailableText;
      default:
        return AppColors.textPrimary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'matched':
        return 'Matched';
      case 'fulfilled':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  Future<void> _accept(String requestId) async {
    try {
      await Backend.instance.acceptRequest(requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've accepted this request. Contact details are below.")),
      );
    } on RequestAlreadyClaimedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Someone else already accepted this request.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not accept. Please try again.')),
      );
    }
  }

  Future<void> _markFulfilled(String requestId) async {
    await Backend.instance.markFulfilled(requestId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for donating! You're on a 90-day cooldown now.")),
    );
  }

  Future<void> _cancel(String requestId) async {
    await Backend.instance.cancelRequest(requestId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cancelled.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Blood requests',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppColors.tabTrackBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(child: _tabButton(context, 'Received')),
                  Expanded(child: _tabButton(context, 'My requests')),
                ],
              ),
            ),
            Expanded(
              child: _activeTab == 'Received' ? _receivedList(context) : _myRequestsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(BuildContext context, String label) {
    final isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.whiteTextOnPrimary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _receivedList(BuildContext context) {
    if (_myBloodGroup == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final compatible = Backend.instance.compatibleRecipientGroups(_myBloodGroup!);
    final myUid = Backend.instance.currentUser?.uid;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Backend.instance.openRequestsStream(),
          builder: (context, snapshot) {
            final docs = (snapshot.data?.docs ?? [])
                .where((d) =>
                    d.data()['requester_uid'] != myUid &&
                    compatible.contains(d.data()['blood_group']))
                .toList();
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (docs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Open requests you can fulfil', style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final doc in docs) ...[
                  _requestCard(context, doc.id, doc.data(), donorAction: 'accept'),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('matched_donor_id', isEqualTo: myUid)
              .where('status', isEqualTo: 'matched')
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text("You've accepted", style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final doc in docs) ...[
                  _requestCard(context, doc.id, doc.data(), donorAction: 'fulfil'),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _myRequestsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Backend.instance.myRequestsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "You haven't sent any requests yet.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _requestCard(context, docs[index].id, docs[index].data(), donorAction: null),
        );
      },
    );
  }

  Widget _requestCard(
    BuildContext context,
    String requestId,
    Map<String, dynamic> request, {
    required String? donorAction,
  }) {
    final status = request['status'] as String? ?? 'open';
    final bloodGroup = request['blood_group'] as String? ?? '';
    final locationLabel = (request['location_label'] as String?)?.isNotEmpty == true
        ? request['location_label'] as String
        : '${request['units_needed'] ?? 1} unit(s) needed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bloodGroup,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusBg(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusText(status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          if (status == 'matched' && request['matched_donor_phone'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${request['matched_donor_name']} · ${request['matched_donor_phone']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (donorAction == 'accept')
            ElevatedButton(
              onPressed: () => _accept(requestId),
              child: const Text('Accept & help'),
            )
          else if (donorAction == 'fulfil')
            ElevatedButton(
              onPressed: () => _markFulfilled(requestId),
              child: const Text('Mark as donated'),
            )
          else if (status == 'open')
            OutlinedButton(
              onPressed: () => _cancel(requestId),
              child: const Text('Cancel request'),
            ),
        ],
      ),
    );
  }
}
