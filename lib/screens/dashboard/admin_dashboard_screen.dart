import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_ride_model.dart';
import '../../services/admin_state_service.dart';
import '../../services/admin_firebase_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final service = AdminStateService();
        final overview = service.dashboardOverview;
        final fb = AdminFirebaseService();

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => service.refreshAllData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AdminDimensions.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Platform Overview',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              service.lastSyncTime != null
                                  ? 'Live operational metrics • Synced ${_formatTime(service.lastSyncTime!)}'
                                  : 'Real-time metrics & operational status',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: service.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh_rounded, color: AdminColors.primary),
                            tooltip: 'Refresh Platform Data',
                            onPressed: service.isLoading ? null : () => service.refreshAllData(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: fb.isFirebaseAvailable
                                  ? AdminColors.success.withOpacity(0.12)
                                  : AdminColors.primaryLight,
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
                              border: Border.all(
                                color: fb.isFirebaseAvailable
                                    ? AdminColors.success.withOpacity(0.3)
                                    : AdminColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  fb.isFirebaseAvailable ? Icons.cloud_done_rounded : Icons.offline_pin_outlined,
                                  size: 14,
                                  color: fb.isFirebaseAvailable ? AdminColors.success : AdminColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fb.isFirebaseAvailable ? 'LIVE FIREBASE' : 'LOCAL FALLBACK',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: fb.isFirebaseAvailable ? AdminColors.success : AdminColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminDimensions.p16),

                  // Optional Error Notice
                  if (service.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AdminDimensions.p16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AdminColors.danger, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.errorMessage!,
                              style: const TextStyle(fontSize: 12, color: AdminColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Loading Bar
                  if (service.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AdminDimensions.p12),
                      child: LinearProgressIndicator(),
                    ),

                  // Empty State Banner if no records exist
                  if (overview.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: AdminDimensions.p20),
                      padding: const EdgeInsets.all(AdminDimensions.p16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cloud_done_rounded, color: AdminColors.primary, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Real-Time Firebase Firestore Connected',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Registered users, captains, rides, and transactions will appear here in real time as activity occurs.',
                                  style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // CORE 8 REQUIRED KPI METRICS GRID
                  const Text(
                    'Core System Indicators',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AdminDimensions.p12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      final crossAxisCount = isWide ? 4 : 2;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AdminDimensions.p12,
                        crossAxisSpacing: AdminDimensions.p12,
                        childAspectRatio: isWide ? 1.55 : 1.25,
                        children: [
                          // 1. Total Users
                          _buildKpiCard(
                            title: 'Total Users',
                            value: '${overview.totalUsers}',
                            subtitle: '${overview.activeUsers} active riders',
                            icon: Icons.people_alt_rounded,
                            color: AdminColors.primary,
                            onTap: () => onNavigate(1), // Users tab
                          ),

                          // 2. Total Captains
                          _buildKpiCard(
                            title: 'Total Captains',
                            value: '${overview.totalCaptains}',
                            subtitle: '${overview.onlineCaptains} online now',
                            icon: Icons.sports_motorsports_rounded,
                            color: AdminColors.purple,
                            onTap: () => onNavigate(2), // Captains tab
                          ),

                          // 3. Verified Captains
                          _buildKpiCard(
                            title: 'Verified Captains',
                            value: '${overview.verifiedCaptains}',
                            subtitle: overview.pendingCaptains > 0
                                ? '${overview.pendingCaptains} pending review'
                                : 'All verified',
                            icon: Icons.verified_user_rounded,
                            color: AdminColors.teal,
                            isHighlight: overview.pendingCaptains > 0,
                            onTap: () => onNavigate(2), // Captains tab
                          ),

                          // 4. Total Rides
                          _buildKpiCard(
                            title: 'Total Rides',
                            value: '${overview.totalRides}',
                            subtitle: 'All-time booked trips',
                            icon: Icons.local_taxi_rounded,
                            color: AdminColors.secondary,
                            onTap: () => onNavigate(3), // Rides tab
                          ),

                          // 5. Completed Rides
                          _buildKpiCard(
                            title: 'Completed Rides',
                            value: '${overview.completedRides}',
                            subtitle: overview.totalRides > 0
                                ? '${((overview.completedRides / overview.totalRides) * 100).toStringAsFixed(1)}% fulfillment'
                                : '0% fulfillment',
                            icon: Icons.check_circle_rounded,
                            color: AdminColors.success,
                            onTap: () => onNavigate(3), // Rides tab
                          ),

                          // 6. Cancelled Rides
                          _buildKpiCard(
                            title: 'Cancelled Rides',
                            value: '${overview.cancelledRides}',
                            subtitle: overview.totalRides > 0
                                ? '${((overview.cancelledRides / overview.totalRides) * 100).toStringAsFixed(1)}% cancellation'
                                : '0% cancellation',
                            icon: Icons.cancel_rounded,
                            color: AdminColors.danger,
                            onTap: () => onNavigate(3), // Rides tab
                          ),

                          // 7. Active Rides
                          _buildKpiCard(
                            title: 'Active Rides',
                            value: '${overview.activeRides}',
                            subtitle: 'Live on the road',
                            icon: Icons.navigation_rounded,
                            color: AdminColors.warning,
                            isHighlight: overview.activeRides > 0,
                            onTap: () => onNavigate(4), // Live monitor tab
                          ),

                          // 8. Total Revenue
                          _buildKpiCard(
                            title: 'Total Revenue',
                            value: '₹${overview.totalRevenue.toStringAsFixed(0)}',
                            subtitle: 'Gross completed fares',
                            icon: Icons.currency_rupee_rounded,
                            color: AdminColors.success,
                            onTap: () => onNavigate(8), // Reports tab
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AdminDimensions.p16),

                  // SECONDARY OPERATIONAL METRIC ROW
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStatCard(
                          title: "Today's Revenue",
                          value: '₹${overview.todayRevenue.toStringAsFixed(0)}',
                          icon: Icons.today_rounded,
                          color: AdminColors.success,
                          onTap: () => onNavigate(8),
                        ),
                      ),
                      const SizedBox(width: AdminDimensions.p12),
                      Expanded(
                        child: _buildMiniStatCard(
                          title: 'Emergency Alerts',
                          value: '${overview.activeEmergencies}',
                          icon: Icons.emergency_rounded,
                          color: overview.activeEmergencies > 0 ? AdminColors.danger : AdminColors.purple,
                          isAlert: overview.activeEmergencies > 0,
                          onTap: () => onNavigate(5),
                        ),
                      ),
                      const SizedBox(width: AdminDimensions.p12),
                      Expanded(
                        child: _buildMiniStatCard(
                          title: 'Pending Complaints',
                          value: '${overview.activeComplaints}',
                          icon: Icons.support_agent_rounded,
                          color: AdminColors.info,
                          onTap: () => onNavigate(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminDimensions.p24),

                  // Quick Navigation Shortcuts
                  const Text(
                    'Quick Management Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AdminDimensions.p12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionBtn(
                          label: 'Emergency SOS Desk',
                          icon: Icons.emergency_rounded,
                          color: AdminColors.danger,
                          onTap: () => onNavigate(5),
                        ),
                        const SizedBox(width: AdminDimensions.p12),
                        _buildQuickActionBtn(
                          label: 'Live Ride Monitor',
                          icon: Icons.map_outlined,
                          color: AdminColors.primary,
                          onTap: () => onNavigate(4),
                        ),
                        const SizedBox(width: AdminDimensions.p12),
                        _buildQuickActionBtn(
                          label: 'View All Users',
                          icon: Icons.group_outlined,
                          color: AdminColors.purple,
                          onTap: () => onNavigate(1),
                        ),
                        const SizedBox(width: AdminDimensions.p12),
                        _buildQuickActionBtn(
                          label: 'Captain Roster',
                          icon: Icons.sports_motorsports_outlined,
                          color: AdminColors.success,
                          onTap: () => onNavigate(2),
                        ),
                        const SizedBox(width: AdminDimensions.p12),
                        _buildQuickActionBtn(
                          label: 'Analytics & Reports',
                          icon: Icons.bar_chart_rounded,
                          color: AdminColors.warning,
                          onTap: () => onNavigate(8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AdminDimensions.p24),

                  // Recent Platform Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Platform Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigate(3), // Go to all rides
                        child: const Row(
                          children: [
                            Text('View All Rides'),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminDimensions.p8),

                  Card(
                    child: service.rides.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(AdminDimensions.p24),
                            child: Center(
                              child: Text(
                                'No recent rides registered yet.',
                                style: TextStyle(color: AdminColors.textMuted),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: service.rides.take(5).length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final ride = service.rides[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(ride.status).withOpacity(0.12),
                                  child: Icon(
                                    _getRideIcon(ride.status),
                                    color: _getStatusColor(ride.status),
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        ride.id,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(ride.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ride.status.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(ride.status),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '₹${ride.fare.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${ride.passengerName} • ${ride.pickupAddress.split(',').first} → ${ride.destinationAddress.split(',').first}',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, color: AdminColors.textMuted),
                                onTap: () => onNavigate(3),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isHighlight = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
      child: Card(
        color: isHighlight ? color.withOpacity(0.04) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
          side: BorderSide(
            color: isHighlight ? color : AdminColors.border,
            width: isHighlight ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AdminDimensions.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? color : AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isAlert = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AdminDimensions.p12),
        decoration: BoxDecoration(
          color: isAlert ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
          border: Border.all(
            color: isAlert ? color : AdminColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isAlert ? color : AdminColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          color: AdminColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.white,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final sec = time.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec';
  }

  Color _getStatusColor(AdminRideStatus status) {
    switch (status) {
      case AdminRideStatus.requested:
        return AdminColors.info;
      case AdminRideStatus.accepted:
        return AdminColors.purple;
      case AdminRideStatus.arrived:
        return AdminColors.teal;
      case AdminRideStatus.inProgress:
        return AdminColors.warning;
      case AdminRideStatus.completed:
        return AdminColors.success;
      case AdminRideStatus.cancelled:
        return AdminColors.danger;
    }
  }

  IconData _getRideIcon(AdminRideStatus status) {
    switch (status) {
      case AdminRideStatus.requested:
        return Icons.hail_rounded;
      case AdminRideStatus.accepted:
        return Icons.thumb_up_alt_rounded;
      case AdminRideStatus.arrived:
        return Icons.pin_drop_rounded;
      case AdminRideStatus.inProgress:
        return Icons.navigation_rounded;
      case AdminRideStatus.completed:
        return Icons.check_circle_rounded;
      case AdminRideStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}
