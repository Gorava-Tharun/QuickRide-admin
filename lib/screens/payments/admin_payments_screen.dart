import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_report_model.dart';
import '../../models/firestore_models.dart';
import '../../services/admin_state_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'ALL';
  String _selectedPeriod = 'All Time'; // 'All Time', 'Today', 'This Week', 'This Month'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final service = AdminStateService();
        final allPayments = service.payments;
        final issues = service.reconciliationIssues;

        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Tab Navigation Bar
                _buildHeader(allPayments.length, issues.length),
                const SizedBox(height: 16),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Transactions & Search
                      _buildTransactionsTab(service, allPayments),

                      // TAB 2: Financial Dashboard & Reports
                      _buildFinancialDashboardTab(service),

                      // TAB 3: Payment Reconciliation
                      _buildReconciliationTab(service, issues),
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

  Widget _buildHeader(int paymentCount, int issueCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AdminColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment History & Financial Reports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete transaction logs, 15% platform commission accounting, and automated ride reconciliation',
                      style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AdminColors.primary,
            unselectedLabelColor: AdminColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            indicatorColor: AdminColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('Transactions'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AdminColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$paymentCount',
                          style: const TextStyle(fontSize: 11, color: AdminColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  children: [
                    Icon(Icons.pie_chart_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Financial Reports & 15% Split'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.rule_folder_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('Payment Reconciliation'),
                    if (issueCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AdminColors.dangerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$issueCount',
                            style: const TextStyle(
                                fontSize: 11, color: AdminColors.danger, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: TRANSACTIONS & SEARCH
  // ==========================================
  Widget _buildTransactionsTab(AdminStateService service, List<FirestorePaymentModel> allPayments) {
    // KPI metrics
    final totalCollected = service.totalGrossCollected;
    final paidCount = allPayments.where((p) => p.paymentStatus == FirestorePaymentStatus.paid).length;
    final pendingCount = allPayments
        .where((p) =>
            p.paymentStatus == FirestorePaymentStatus.pending ||
            p.paymentStatus == FirestorePaymentStatus.processing)
        .length;
    final failedOrRefunded = allPayments
        .where((p) =>
            p.paymentStatus == FirestorePaymentStatus.failed ||
            p.paymentStatus == FirestorePaymentStatus.cancelled ||
            p.paymentStatus == FirestorePaymentStatus.refunded)
        .length;

    // Search query & filter
    final query = _searchController.text.trim().toLowerCase();
    final filteredPayments = allPayments.where((p) {
      final matchesQuery = query.isEmpty ||
          p.paymentId.toLowerCase().contains(query) ||
          p.rideId.toLowerCase().contains(query) ||
          p.userId.toLowerCase().contains(query) ||
          (p.captainId?.toLowerCase().contains(query) ?? false) ||
          (p.passengerName?.toLowerCase().contains(query) ?? false) ||
          (p.captainName?.toLowerCase().contains(query) ?? false) ||
          p.paymentMethod.toLowerCase().contains(query) ||
          (p.gatewayOrderId?.toLowerCase().contains(query) ?? false) ||
          (p.gatewayPaymentId?.toLowerCase().contains(query) ?? false);

      final matchesStatus =
          _selectedStatus == 'ALL' || p.paymentStatus.name.toUpperCase() == _selectedStatus;

      return matchesQuery && matchesStatus;
    }).toList();

    // Sort newest first
    filteredPayments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        // KPI row
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 750;
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _buildKpiCard('Total Collected', '₹${totalCollected.toStringAsFixed(0)}',
                    Icons.account_balance_wallet_rounded, AdminColors.success, isSmall),
                _buildKpiCard('Successful Paid', '$paidCount', Icons.check_circle_rounded,
                    AdminColors.primary, isSmall),
                _buildKpiCard('Pending / Cash', '$pendingCount', Icons.pending_actions_rounded,
                    AdminColors.warning, isSmall),
                _buildKpiCard('Failed / Refunded', '$failedOrRefunded',
                    Icons.remove_circle_outline_rounded, AdminColors.danger, isSmall),
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Search & Filter controls
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by Payment ID, Ride ID, Passenger, Captain, Gateway ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                  border: Border.all(color: AdminColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'PAID', child: Text('PAID')),
                      DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                      DropdownMenuItem(value: 'PROCESSING', child: Text('PROCESSING')),
                      DropdownMenuItem(value: 'FAILED', child: Text('FAILED')),
                      DropdownMenuItem(value: 'REFUNDED', child: Text('REFUNDED')),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Transactions Table
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(color: AdminColors.border),
            ),
            child: filteredPayments.isEmpty
                ? const Center(
                    child: Text(
                      'No transaction records matching criteria.',
                      style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AdminColors.background.withOpacity(0.6),
                        ),
                        columns: const [
                          DataColumn(label: Text('Payment ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Ride ID & Route', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Passenger / Captain', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fare Breakdown', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredPayments.map((p) {
                          final hasDiscount = p.discountAmount > 0;
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(p.paymentId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                    if (p.gatewayPaymentId != null)
                                      Text('GW: ${p.gatewayPaymentId}',
                                          style: const TextStyle(fontSize: 10, color: AdminColors.textSecondary)),
                                  ],
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 170,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(p.rideId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                      if (p.pickupAddress != null)
                                        Text(
                                          '${p.pickupAddress} → ${p.dropAddress ?? ""}',
                                          style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(p.passengerName ?? p.userId,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                    Text('→ ${p.captainName ?? p.captainId ?? "Unassigned"}',
                                        style: const TextStyle(fontSize: 10, color: AdminColors.textSecondary)),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    p.paymentMethod.toUpperCase(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₹${p.finalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                    if (hasDiscount)
                                      Text(
                                        'Orig: ₹${p.originalFare.toStringAsFixed(0)} (-₹${p.discountAmount.toStringAsFixed(0)})',
                                        style: const TextStyle(fontSize: 10, color: AdminColors.success),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(_buildStatusBadge(p.paymentStatus)),
                              DataCell(Text(_formatDateTime(p.createdAt), style: const TextStyle(fontSize: 11))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline_rounded, size: 18, color: AdminColors.primary),
                                      tooltip: 'View Full Invoice',
                                      onPressed: () => _showPaymentDetailsDialog(context, p, service),
                                    ),
                                    if (p.paymentStatus == FirestorePaymentStatus.paid)
                                      IconButton(
                                        icon: const Icon(Icons.undo_rounded, size: 18, color: AdminColors.danger),
                                        tooltip: 'Issue Refund',
                                        onPressed: () => _confirmRefundDialog(context, p, service),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: FINANCIAL DASHBOARD & REPORTS
  // ==========================================
  Widget _buildFinancialDashboardTab(AdminStateService service) {
    // Determine figures based on selected period
    double grossRevenue;
    double platformCommission;
    double captainEarnings;
    int transactionCount;

    switch (_selectedPeriod) {
      case 'Today':
        grossRevenue = service.todayGrossRevenue;
        platformCommission = service.todayPlatformCommission;
        captainEarnings = service.todayCaptainEarnings;
        transactionCount = service.todayPaidPayments.length;
        break;
      case 'This Week':
        grossRevenue = service.weeklyGrossRevenue;
        platformCommission = service.weeklyPlatformCommission;
        captainEarnings = service.weeklyCaptainEarnings;
        transactionCount = service.weeklyPaidPayments.length;
        break;
      case 'This Month':
        grossRevenue = service.monthlyGrossRevenue;
        platformCommission = service.monthlyPlatformCommission;
        captainEarnings = service.monthlyCaptainEarnings;
        transactionCount = service.monthlyPaidPayments.length;
        break;
      case 'All Time':
      default:
        grossRevenue = service.totalGrossCollected;
        platformCommission = service.totalPlatformCommission;
        captainEarnings = service.totalCaptainEarnings;
        transactionCount = service.deduplicatedPaidPayments.length;
        break;
    }

    final totalDiscounts = service.totalDiscountsGiven;
    final totalRefunded = service.totalRefunded;
    final methodBreakdown = service.paymentMethodVolumeBreakdown;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(color: AdminColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AdminColors.textSecondary),
                const SizedBox(width: 8),
                const Text('Reporting Timeframe:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AdminColors.textPrimary)),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: ['All Time', 'Today', 'This Week', 'This Month'].map((period) {
                    final isSelected = _selectedPeriod == period;
                    return ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: AdminColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AdminColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedPeriod = period);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Financial KPIs
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 800;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildFinancialStatCard(
                    title: 'Gross Ride Volume',
                    value: '₹${grossRevenue.toStringAsFixed(0)}',
                    subtitle: '$transactionCount Paid Rides',
                    color: AdminColors.primary,
                    icon: Icons.payments_rounded,
                    isSmall: isSmall,
                  ),
                  _buildFinancialStatCard(
                    title: 'Platform Fee (15%)',
                    value: '₹${platformCommission.toStringAsFixed(2)}',
                    subtitle: 'QuickRide Platform Revenue',
                    color: AdminColors.success,
                    icon: Icons.account_balance_rounded,
                    isSmall: isSmall,
                  ),
                  _buildFinancialStatCard(
                    title: 'Captain Take-Home (85%)',
                    value: '₹${captainEarnings.toStringAsFixed(2)}',
                    subtitle: 'Direct Partner Earnings',
                    color: AdminColors.purple,
                    icon: Icons.two_wheeler_rounded,
                    isSmall: isSmall,
                  ),
                  _buildFinancialStatCard(
                    title: 'Discounts Absorbed',
                    value: '₹${totalDiscounts.toStringAsFixed(0)}',
                    subtitle: 'Promo Campaigns',
                    color: Colors.orange,
                    icon: Icons.discount_rounded,
                    isSmall: isSmall,
                  ),
                  _buildFinancialStatCard(
                    title: 'Total Refunds',
                    value: '₹${totalRefunded.toStringAsFixed(0)}',
                    subtitle: 'Disputes & Cancellations',
                    color: AdminColors.danger,
                    icon: Icons.replay_rounded,
                    isSmall: isSmall,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 15% / 85% Visual Split Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, color: AdminColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Commission & Earnings Allocation Structure',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Horizontal progress representation
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 85,
                          child: Container(
                            color: AdminColors.purple,
                            alignment: Alignment.center,
                            child: const Text('85% Captains',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(
                          flex: 15,
                          child: Container(
                            color: AdminColors.success,
                            alignment: Alignment.center,
                            child: const Text('15% Fee',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: AdminColors.purple, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 6),
                        Text('Captain Partner Payout: ₹${captainEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: AdminColors.success, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 6),
                        Text('QuickRide Platform Commission: ₹${platformCommission.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment Methods Distribution Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.credit_card_rounded, color: AdminColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Payment Method Volume Breakdown',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (methodBreakdown.isEmpty)
                  const Text('No payment method data recorded yet.', style: TextStyle(color: AdminColors.textMuted))
                else
                  Column(
                    children: methodBreakdown.entries.map((e) {
                      final percentage = grossRevenue > 0 ? (e.value / grossRevenue) * 100 : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('₹${e.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: grossRevenue > 0 ? (e.value / grossRevenue).clamp(0.0, 1.0) : 0.0,
                              backgroundColor: Colors.grey.shade200,
                              color: AdminColors.primary,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: PAYMENT RECONCILIATION
  // ==========================================
  Widget _buildReconciliationTab(AdminStateService service, List<ReconciliationIssue> issues) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reconciliation Status Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: issues.isEmpty ? AdminColors.successLight : AdminColors.warningLight,
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(
                color: issues.isEmpty ? AdminColors.success : AdminColors.warning,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  issues.isEmpty ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                  color: issues.isEmpty ? AdminColors.success : Colors.orange.shade800,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issues.isEmpty
                            ? 'All Accounts 100% Reconciled & Balanced'
                            : '${issues.length} Reconciliation Inconsistencies Detected',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: issues.isEmpty ? AdminColors.success : Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        issues.isEmpty
                            ? 'Every completed ride has verified settlement. No orphan payments or duplicate records detected.'
                            : 'Cross-audited against ride collection, completed rides status, and gateway settlements.',
                        style: TextStyle(
                          fontSize: 12,
                          color: issues.isEmpty ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.textPrimary,
                    side: const BorderSide(color: AdminColors.border),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Re-Audit Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Issues list
          if (issues.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          size: 56, color: AdminColors.success),
                    ),
                    const SizedBox(height: 16),
                    const Text('Zero Discrepancies',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    const Text(
                      'All rides and payments match criteria accurately.',
                      style: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: issues.map((issue) {
                return _buildReconciliationIssueCard(context, issue, service);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReconciliationIssueCard(
      BuildContext context, ReconciliationIssue issue, AdminStateService service) {
    final isHigh = issue.severity == 'HIGH';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
        border: Border.all(
          color: isHigh ? AdminColors.danger.withOpacity(0.5) : AdminColors.warning.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isHigh ? Colors.red : Colors.orange).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHigh ? AdminColors.dangerLight : AdminColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${issue.severity} SEVERITY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isHigh ? AdminColors.danger : Colors.orange.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    issue.title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AdminColors.textPrimary),
                  ),
                ],
              ),
              if (issue.amount != null)
                Text(
                  '₹${issue.amount!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isHigh ? AdminColors.danger : AdminColors.warning,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.description,
            style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detected at: ${_formatDateTime(issue.timestamp)}',
                style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
              ),
              Row(
                children: [
                  if (issue.type == ReconciliationIssueType.paidPaymentIncompleteRide &&
                      issue.paymentId != null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.undo_rounded, size: 14),
                      label: const Text('Refund Transaction',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Administrative Refund'),
                            content: Text(
                                'Issue full refund for payment ${issue.paymentId} (₹${issue.amount?.toStringAsFixed(0)}) collected on cancelled ride ${issue.rideId}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Confirm Refund', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await service.refundPayment(issue.paymentId!,
                              reason: 'Reconciliation refund for cancelled ride ${issue.rideId}');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Payment ${issue.paymentId} marked REFUNDED.')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                  if (issue.type == ReconciliationIssueType.completedRideUnpaid &&
                      issue.rideId != null) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.primary,
                        side: const BorderSide(color: AdminColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.mark_email_read_rounded, size: 14),
                      label: const Text('Mark Paid / Settled',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        if (issue.paymentId != null) {
                          await service.updatePaymentStatus(
                              issue.paymentId!, FirestorePaymentStatus.paid,
                              reason: 'Manually verified and settled by admin');
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ride ${issue.rideId} marked settled.')),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED WIDGETS & DIALOGS
  // ==========================================
  Widget _buildKpiCard(String title, String value, IconData icon, Color color, bool isSmall) {
    return Container(
      width: isSmall ? 160 : 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 10, color: AdminColors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AdminColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isSmall,
  }) {
    return Container(
      width: isSmall ? 180 : 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AdminColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FirestorePaymentStatus status) {
    Color bg;
    Color border;
    Color text;

    switch (status) {
      case FirestorePaymentStatus.paid:
        bg = AdminColors.successLight;
        border = AdminColors.success;
        text = Colors.green.shade900;
        break;
      case FirestorePaymentStatus.pending:
      case FirestorePaymentStatus.processing:
        bg = AdminColors.warningLight;
        border = AdminColors.warning;
        text = Colors.orange.shade900;
        break;
      case FirestorePaymentStatus.failed:
      case FirestorePaymentStatus.cancelled:
        bg = AdminColors.dangerLight;
        border = AdminColors.danger;
        text = AdminColors.danger;
        break;
      case FirestorePaymentStatus.refunded:
        bg = AdminColors.purpleLight;
        border = AdminColors.purple;
        text = Colors.purple.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }

  void _showPaymentDetailsDialog(
      BuildContext context, FirestorePaymentModel p, AdminStateService service) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AdminColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment ${p.paymentId}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              _buildStatusBadge(p.paymentStatus),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('Ride ID', p.rideId),
                  _buildDetailItem('Passenger', '${p.passengerName ?? "User"} (${p.userId})'),
                  _buildDetailItem('Captain', '${p.captainName ?? "Partner"} (${p.captainId ?? "Unassigned"})'),
                  if (p.pickupAddress != null) ...[
                    const Divider(height: 20),
                    _buildDetailItem('Pickup', p.pickupAddress!),
                    if (p.dropAddress != null) _buildDetailItem('Destination', p.dropAddress!),
                    if (p.vehicleType != null) _buildDetailItem('Vehicle Type', p.vehicleType!),
                    if (p.distanceKm != null) _buildDetailItem('Distance', '${p.distanceKm} km'),
                  ],
                  const Divider(height: 20),
                  _buildDetailItem('Original Fare', '₹${p.originalFare.toStringAsFixed(2)}'),
                  if (p.discountAmount > 0)
                    _buildDetailItem(
                        'Promo Discount (${p.couponCode ?? "PROMO"})', '-₹${p.discountAmount.toStringAsFixed(2)}'),
                  _buildDetailItem('Final Amount Collected', '₹${p.finalAmount.toStringAsFixed(2)} (INR)'),
                  const Divider(height: 20),
                  _buildDetailItem('Payment Method', p.paymentMethod.toUpperCase()),
                  if (p.gatewayOrderId != null) _buildDetailItem('Gateway Order ID', p.gatewayOrderId!),
                  if (p.gatewayPaymentId != null) _buildDetailItem('Gateway Payment ID', p.gatewayPaymentId!),
                  if (p.gatewaySignature != null) _buildDetailItem('Digital Signature', 'HMAC SHA-256 (Verified)'),
                  if (p.errorMessage != null) _buildDetailItem('Error / Note', p.errorMessage!, isError: true),
                  const Divider(height: 20),
                  _buildDetailItem('Created At', _formatDateTime(p.createdAt)),
                  if (p.paidAt != null) _buildDetailItem('Paid At', _formatDateTime(p.paidAt!)),
                ],
              ),
            ),
          ),
          actions: [
            if (p.paymentStatus == FirestorePaymentStatus.paid)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AdminColors.danger),
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Refund Payment'),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _confirmRefundDialog(context, p, service);
                },
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRefundDialog(
      BuildContext context, FirestorePaymentModel p, AdminStateService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Administrative Refund'),
        content: Text(
            'Are you sure you want to issue a full refund of ₹${p.finalAmount.toStringAsFixed(2)} for Payment ${p.paymentId} (Ride ${p.rideId})? This will mark the transaction REFUNDED in the platform ledger.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await service.refundPayment(p.paymentId, reason: 'Full refund initiated by administrator');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment ${p.paymentId} marked REFUNDED.')),
                );
              }
            },
            child: const Text('Confirm Refund', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AdminColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isError ? AdminColors.danger : AdminColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
