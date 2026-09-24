import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_report_model.dart';
import '../../services/admin_state_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final service = AdminStateService();
        final rideStats = service.rideReportStats;
        final userStats = service.userReportStats;
        final captainStats = service.captainReportStats;
        final revenueStats = service.revenueReportStats;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform Analytics & Reports',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Comprehensive real-time reporting across Rides, Revenue, Users, and Fleet',
                            style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AdminColors.primary),
                      tooltip: 'Refresh Reports',
                      onPressed: () => service.refreshAllData(),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p12),

                // Report Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AdminColors.primary,
                    unselectedLabelColor: AdminColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    indicatorColor: AdminColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.currency_rupee_rounded, size: 18), text: 'Revenue & Payments'),
                      Tab(icon: Icon(Icons.local_taxi_rounded, size: 18), text: 'Ride Analytics'),
                      Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'User Reports'),
                      Tab(icon: Icon(Icons.sports_motorsports_rounded, size: 18), text: 'Captain & Fleet'),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p12),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRevenueReportTab(revenueStats),
                      _buildRideReportTab(rideStats),
                      _buildUserReportTab(userStats),
                      _buildCaptainReportTab(captainStats),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // 1. REVENUE & FINANCIAL REPORTS
  // ==========================================================================
  Widget _buildRevenueReportTab(AdminRevenueReportStats stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Trend Highlights Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AdminDimensions.p12,
                crossAxisSpacing: AdminDimensions.p12,
                childAspectRatio: isWide ? 1.6 : 1.3,
                children: [
                  _buildReportMetricCard(
                    title: 'Total Gross Collected',
                    amount: '₹${stats.totalGrossCollected.toStringAsFixed(0)}',
                    subtitle: 'Completed rides',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AdminColors.success,
                  ),
                  _buildReportMetricCard(
                    title: "Today's Revenue",
                    amount: '₹${stats.todayGrossRevenue.toStringAsFixed(0)}',
                    subtitle: 'Daily volume',
                    icon: Icons.today_rounded,
                    color: AdminColors.primary,
                  ),
                  _buildReportMetricCard(
                    title: "This Week's Revenue",
                    amount: '₹${stats.weeklyGrossRevenue.toStringAsFixed(0)}',
                    subtitle: 'Past 7 days',
                    icon: Icons.calendar_view_week_rounded,
                    color: AdminColors.purple,
                  ),
                  _buildReportMetricCard(
                    title: "This Month's Revenue",
                    amount: '₹${stats.monthlyGrossRevenue.toStringAsFixed(0)}',
                    subtitle: 'Billing month',
                    icon: Icons.calendar_month_rounded,
                    color: AdminColors.warning,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Platform Commission vs Captain Payouts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Distribution & Payout Split',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Standard 15% Platform Commission vs 85% Captain Payouts model',
                    style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 15,
                            child: Container(color: AdminColors.primary),
                          ),
                          Expanded(
                            flex: 85,
                            child: Container(color: AdminColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _buildLegendItem(
                        color: AdminColors.primary,
                        label: 'Platform Commission (15%)',
                        value: '₹${stats.totalPlatformCommission.toStringAsFixed(0)}',
                      ),
                      _buildLegendItem(
                        color: AdminColors.success,
                        label: 'Captain Earnings (85%)',
                        value: '₹${stats.totalCaptainEarnings.toStringAsFixed(0)}',
                      ),
                      _buildLegendItem(
                        color: AdminColors.danger,
                        label: 'Refunds (${stats.totalRefundsCount})',
                        value: '₹${stats.totalRefundAmount.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Payment Status Breakdown & Methods
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (!isWide) {
                return Column(
                  children: [
                    _buildPaymentStatusCard(stats),
                    const SizedBox(height: AdminDimensions.p12),
                    _buildPaymentMethodCard(stats),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPaymentStatusCard(stats)),
                  const SizedBox(width: AdminDimensions.p16),
                  Expanded(child: _buildPaymentMethodCard(stats)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(AdminRevenueReportStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Status Summary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              label: 'PAID',
              count: stats.paymentStatusCounts['PAID'] ?? 0,
              amount: stats.paymentStatusAmounts['PAID'] ?? 0.0,
              color: AdminColors.success,
            ),
            const Divider(height: 16),
            _buildStatusRow(
              label: 'PENDING',
              count: stats.paymentStatusCounts['PENDING'] ?? 0,
              amount: stats.paymentStatusAmounts['PENDING'] ?? 0.0,
              color: AdminColors.warning,
            ),
            const Divider(height: 16),
            _buildStatusRow(
              label: 'REFUNDED',
              count: stats.paymentStatusCounts['REFUNDED'] ?? 0,
              amount: stats.paymentStatusAmounts['REFUNDED'] ?? 0.0,
              color: AdminColors.purple,
            ),
            const Divider(height: 16),
            _buildStatusRow(
              label: 'FAILED',
              count: stats.paymentStatusCounts['FAILED'] ?? 0,
              amount: stats.paymentStatusAmounts['FAILED'] ?? 0.0,
              color: AdminColors.danger,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(AdminRevenueReportStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (stats.paymentMethodBreakdown.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No payment method data available', style: TextStyle(color: AdminColors.textMuted)),
                ),
              )
            else
              ...stats.paymentMethodBreakdown.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_getMethodIcon(e.key), size: 16, color: AdminColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            e.key.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        '₹${e.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 2. RIDE REPORTS TAB
  // ==========================================================================
  Widget _buildRideReportTab(AdminRideReportStats stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Volume cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AdminDimensions.p12,
                crossAxisSpacing: AdminDimensions.p12,
                childAspectRatio: isWide ? 1.6 : 1.3,
                children: [
                  _buildReportMetricCard(
                    title: 'Total Rides',
                    amount: '${stats.totalRides}',
                    subtitle: '${stats.activeRides} in progress',
                    icon: Icons.local_taxi_rounded,
                    color: AdminColors.primary,
                  ),
                  _buildReportMetricCard(
                    title: 'Completed Rides',
                    amount: '${stats.completedRides}',
                    subtitle: '${stats.completionRate.toStringAsFixed(1)}% fulfillment',
                    icon: Icons.check_circle_rounded,
                    color: AdminColors.success,
                  ),
                  _buildReportMetricCard(
                    title: 'Cancelled Rides',
                    amount: '${stats.cancelledRides}',
                    subtitle: '${stats.cancellationRate.toStringAsFixed(1)}% cancellation',
                    icon: Icons.cancel_rounded,
                    color: AdminColors.danger,
                  ),
                  _buildReportMetricCard(
                    title: 'Average Ride Fare',
                    amount: '₹${stats.averageRideFare.toStringAsFixed(0)}',
                    subtitle: '${stats.averageRideDistance.toStringAsFixed(1)} km avg distance',
                    icon: Icons.timeline_rounded,
                    color: AdminColors.purple,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Vehicle Type Breakdown (Bike, Auto, Car)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rides by Vehicle Type: Bike, Auto, Car',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fleet distribution, booking volume, and gross revenue by vehicle category',
                    style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      if (!isWide) {
                        return Column(
                          children: [
                            _buildVehicleCategoryCard(
                              category: 'Bike Taxi',
                              count: stats.ridesByVehicleType['Bike'] ?? 0,
                              revenue: stats.revenueByVehicleType['Bike'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.two_wheeler_rounded,
                              color: AdminColors.primary,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildVehicleCategoryCard(
                              category: 'Auto Rickshaw',
                              count: stats.ridesByVehicleType['Auto'] ?? 0,
                              revenue: stats.revenueByVehicleType['Auto'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.electric_rickshaw_rounded,
                              color: AdminColors.warning,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildVehicleCategoryCard(
                              category: 'Cab / Car',
                              count: stats.ridesByVehicleType['Car'] ?? 0,
                              revenue: stats.revenueByVehicleType['Car'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.directions_car_rounded,
                              color: AdminColors.purple,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildVehicleCategoryCard(
                              category: 'Bike Taxi',
                              count: stats.ridesByVehicleType['Bike'] ?? 0,
                              revenue: stats.revenueByVehicleType['Bike'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.two_wheeler_rounded,
                              color: AdminColors.primary,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildVehicleCategoryCard(
                              category: 'Auto Rickshaw',
                              count: stats.ridesByVehicleType['Auto'] ?? 0,
                              revenue: stats.revenueByVehicleType['Auto'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.electric_rickshaw_rounded,
                              color: AdminColors.warning,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildVehicleCategoryCard(
                              category: 'Cab / Car',
                              count: stats.ridesByVehicleType['Car'] ?? 0,
                              revenue: stats.revenueByVehicleType['Car'] ?? 0.0,
                              totalRides: stats.totalRides,
                              icon: Icons.directions_car_rounded,
                              color: AdminColors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Daily, Weekly, Monthly Ride Dynamics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ride Volume Dynamics (Daily / Weekly / Monthly)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      if (!isWide) {
                        return Column(
                          children: [
                            _buildTimeframeCard(
                              label: 'Daily Rides',
                              count: '${stats.dailyRides}',
                              subtitle: 'Booked today',
                              icon: Icons.today_rounded,
                              color: AdminColors.primary,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildTimeframeCard(
                              label: 'Weekly Rides',
                              count: '${stats.weeklyRides}',
                              subtitle: 'Last 7 days',
                              icon: Icons.date_range_rounded,
                              color: AdminColors.purple,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildTimeframeCard(
                              label: 'Monthly Rides',
                              count: '${stats.monthlyRides}',
                              subtitle: 'Current billing month',
                              icon: Icons.calendar_month_rounded,
                              color: AdminColors.teal,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Daily Rides',
                              count: '${stats.dailyRides}',
                              subtitle: 'Booked today',
                              icon: Icons.today_rounded,
                              color: AdminColors.primary,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Weekly Rides',
                              count: '${stats.weeklyRides}',
                              subtitle: 'Last 7 days',
                              icon: Icons.date_range_rounded,
                              color: AdminColors.purple,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Monthly Rides',
                              count: '${stats.monthlyRides}',
                              subtitle: 'Current billing month',
                              icon: Icons.calendar_month_rounded,
                              color: AdminColors.teal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. USER REPORTS TAB
  // ==========================================================================
  Widget _buildUserReportTab(AdminUserReportStats stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AdminDimensions.p12,
                crossAxisSpacing: AdminDimensions.p12,
                childAspectRatio: isWide ? 1.6 : 1.3,
                children: [
                  _buildReportMetricCard(
                    title: 'Total Users',
                    amount: '${stats.totalUsers}',
                    subtitle: 'Customer base',
                    icon: Icons.group_rounded,
                    color: AdminColors.primary,
                  ),
                  _buildReportMetricCard(
                    title: 'Active Users',
                    amount: '${stats.activeUsers}',
                    subtitle: stats.totalUsers > 0
                        ? '${((stats.activeUsers / stats.totalUsers) * 100).toStringAsFixed(1)}% active'
                        : '0% active',
                    icon: Icons.check_circle_rounded,
                    color: AdminColors.success,
                  ),
                  _buildReportMetricCard(
                    title: 'Inactive / Suspended',
                    amount: '${stats.inactiveUsers}',
                    subtitle: 'Restricted accounts',
                    icon: Icons.block_rounded,
                    color: AdminColors.danger,
                  ),
                  _buildReportMetricCard(
                    title: 'Avg Rides / Rider',
                    amount: stats.averageRidesPerUser.toStringAsFixed(1),
                    subtitle: '${stats.usersWithCompletedRides} active riders',
                    icon: Icons.bar_chart_rounded,
                    color: AdminColors.purple,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminDimensions.p16),

          // User Registration Trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Registration Statistics Over Time',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rider acquisition and onboarding rate across timeframes',
                    style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      if (!isWide) {
                        return Column(
                          children: [
                            _buildTimeframeCard(
                              label: 'Registered Today',
                              count: '${stats.usersRegisteredToday}',
                              subtitle: 'New signups today',
                              icon: Icons.person_add_alt_1_rounded,
                              color: AdminColors.primary,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildTimeframeCard(
                              label: 'Registered This Week',
                              count: '${stats.usersRegisteredThisWeek}',
                              subtitle: 'Past 7 days signups',
                              icon: Icons.group_add_rounded,
                              color: AdminColors.purple,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildTimeframeCard(
                              label: 'Registered This Month',
                              count: '${stats.usersRegisteredThisMonth}',
                              subtitle: 'Current month signups',
                              icon: Icons.calendar_month_rounded,
                              color: AdminColors.success,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Registered Today',
                              count: '${stats.usersRegisteredToday}',
                              subtitle: 'New signups today',
                              icon: Icons.person_add_alt_1_rounded,
                              color: AdminColors.primary,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Registered This Week',
                              count: '${stats.usersRegisteredThisWeek}',
                              subtitle: 'Past 7 days signups',
                              icon: Icons.group_add_rounded,
                              color: AdminColors.purple,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildTimeframeCard(
                              label: 'Registered This Month',
                              count: '${stats.usersRegisteredThisMonth}',
                              subtitle: 'Current month signups',
                              icon: Icons.calendar_month_rounded,
                              color: AdminColors.success,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. CAPTAIN & FLEET REPORTS TAB
  // ==========================================================================
  Widget _buildCaptainReportTab(AdminCaptainReportStats stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AdminDimensions.p12,
                crossAxisSpacing: AdminDimensions.p12,
                childAspectRatio: isWide ? 1.6 : 1.3,
                children: [
                  _buildReportMetricCard(
                    title: 'Total Captains',
                    amount: '${stats.totalCaptains}',
                    subtitle: 'Registered partners',
                    icon: Icons.sports_motorsports_rounded,
                    color: AdminColors.primary,
                  ),
                  _buildReportMetricCard(
                    title: 'Verified Captains',
                    amount: '${stats.verifiedCaptains}',
                    subtitle: '${stats.pendingCaptains} pending review',
                    icon: Icons.verified_user_rounded,
                    color: AdminColors.teal,
                  ),
                  _buildReportMetricCard(
                    title: 'Online on Duty',
                    amount: '${stats.onlineCaptains}',
                    subtitle: '${stats.offlineCaptains} offline',
                    icon: Icons.online_prediction_rounded,
                    color: AdminColors.success,
                  ),
                  _buildReportMetricCard(
                    title: 'Fleet Average Rating',
                    amount: '⭐ ${stats.averageRating.toStringAsFixed(2)}',
                    subtitle: '${stats.averageCompletedRides.toStringAsFixed(0)} avg trips',
                    icon: Icons.star_rounded,
                    color: AdminColors.warning,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Fleet distribution by vehicle type
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Captain Fleet Distribution by Vehicle Category',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      if (!isWide) {
                        return Column(
                          children: [
                            _buildFleetCategory(
                              label: 'Bike Captains',
                              count: stats.captainsByVehicleType['Bike'] ?? 0,
                              icon: Icons.two_wheeler_rounded,
                              color: AdminColors.primary,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildFleetCategory(
                              label: 'Auto Captains',
                              count: stats.captainsByVehicleType['Auto'] ?? 0,
                              icon: Icons.electric_rickshaw_rounded,
                              color: AdminColors.warning,
                            ),
                            const SizedBox(height: AdminDimensions.p8),
                            _buildFleetCategory(
                              label: 'Cab / Car Captains',
                              count: stats.captainsByVehicleType['Car'] ?? 0,
                              icon: Icons.directions_car_rounded,
                              color: AdminColors.purple,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildFleetCategory(
                              label: 'Bike Captains',
                              count: stats.captainsByVehicleType['Bike'] ?? 0,
                              icon: Icons.two_wheeler_rounded,
                              color: AdminColors.primary,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildFleetCategory(
                              label: 'Auto Captains',
                              count: stats.captainsByVehicleType['Auto'] ?? 0,
                              icon: Icons.electric_rickshaw_rounded,
                              color: AdminColors.warning,
                            ),
                          ),
                          const SizedBox(width: AdminDimensions.p12),
                          Expanded(
                            child: _buildFleetCategory(
                              label: 'Cab / Car Captains',
                              count: stats.captainsByVehicleType['Car'] ?? 0,
                              icon: Icons.directions_car_rounded,
                              color: AdminColors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminDimensions.p16),

          // Top Performing Captains Leaderboard
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Performing Captains Leaderboard',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Captains ranked by total completed rides and passenger feedback rating',
                    style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  if (stats.topCaptains.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text('No captain records registered yet.', style: TextStyle(color: AdminColors.textMuted)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.topCaptains.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final cap = stats.topCaptains[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: i == 0
                                ? AdminColors.warning.withOpacity(0.2)
                                : AdminColors.primaryLight,
                            child: Text(
                              '#${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: i == 0 ? AdminColors.warning : AdminColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            cap.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${cap.vehicleType} • ${cap.vehicleNumber} • ${cap.verificationStatus}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AdminColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${cap.completedRides} trips',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AdminColors.success,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '⭐ ${cap.rating.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildReportMetricCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
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
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCategoryCard({
    required String category,
    required int count,
    required double revenue,
    required int totalRides,
    required IconData icon,
    required Color color,
  }) {
    final pct = totalRides > 0 ? (count / totalRides * 100).toStringAsFixed(1) : '0';
    return Container(
      padding: const EdgeInsets.all(AdminDimensions.p12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$count rides ($pct%)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${revenue.toStringAsFixed(0)} revenue',
            style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeCard({
    required String label,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminDimensions.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  count,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetCategory({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminDimensions.p12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count partners',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required String label,
    required int count,
    required double amount,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        Text(
          '$count txs • ₹${amount.toStringAsFixed(0)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
        ),
      ],
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Icons.qr_code_scanner_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'netbanking':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.payments_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}
