import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _activeTab = 'Received';

  final List<Map<String, dynamic>> _receivedRequests = [
    {
      'bloodGroup': 'O+',
      'status': 'Urgent',
      'location': 'City Hospital',
      'distance': '2.4 km away',
    },
    {
      'bloodGroup': 'A-',
      'status': 'Pending',
      'location': 'General Clinic, North Block',
      'distance': '1.8 km away',
    },
  ];

  final List<Map<String, dynamic>> _myRequests = [
    {
      'bloodGroup': 'B+',
      'status': 'Accepted',
      'location': 'Metro Diagnostics',
      'distance': '3.2 km away',
    },
    {
      'bloodGroup': 'O-',
      'status': 'Completed',
      'location': 'St. Johns Medical Center',
      'distance': '4.5 km away',
    },
  ];

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Urgent':
        return AppColors.statusUrgentBg;
      case 'Pending':
        return AppColors.statusPendingBg;
      case 'Accepted':
        return AppColors.statusAvailableBg;
      case 'Completed':
        return AppColors.statusCompletedBg;
      default:
        return AppColors.border;
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'Urgent':
        return AppColors.statusUrgentText;
      case 'Pending':
        return AppColors.statusPendingText;
      case 'Accepted':
        return AppColors.statusAvailableText;
      case 'Completed':
        return AppColors.statusCompletedText;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _activeTab == 'Received' ? _receivedRequests : _myRequests;

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
                color: const Color.fromARGB(15, 26, 26, 26), // subtle neutral border/shadow shade
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'Received'),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 'Received'
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Received',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _activeTab == 'Received'
                                    ? AppColors.whiteTextOnPrimary
                                    : AppColors.textSecondary,
                                fontWeight: _activeTab == 'Received'
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'My requests'),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 'My requests'
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'My requests',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _activeTab == 'My requests'
                                    ? AppColors.whiteTextOnPrimary
                                    : AppColors.textSecondary,
                                fontWeight: _activeTab == 'My requests'
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Request List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: activeList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = activeList[index];
                  final status = request['status'] as String;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            // Blood group Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['bloodGroup'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBg(status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
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

                        // Location Detail Row
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${request['distance']} · ${request['location']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // View details action
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Viewing request details for ${request['bloodGroup']}...',
                                ),
                              ),
                            );
                          },
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
