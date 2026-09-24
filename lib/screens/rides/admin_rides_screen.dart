import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_ride_model.dart';
import '../../models/firestore_models.dart';
import '../../services/admin_state_service.dart';
import '../../services/admin_chat_service.dart';

class AdminRidesScreen extends StatefulWidget {
  const AdminRidesScreen({super.key});

  @override
  State<AdminRidesScreen> createState() => _AdminRidesScreenState();
}

class _AdminRidesScreenState extends State<AdminRidesScreen> {
  String _searchQuery = '';
  AdminRideStatus? _statusFilter;

  void _showRideDetailsModal(AdminRideModel ride) {
    final adminState = AdminStateService();
    final matchingPayment =
        adminState.payments.where((p) => p.rideId == ride.id).firstOrNull;
    final canProcessRefund = matchingPayment != null &&
        matchingPayment.paymentStatus == FirestorePaymentStatus.paid &&
        ride.isCancelled &&
        !ride.isRefunded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AdminDimensions.radiusLarge)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AdminDimensions.p24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.id,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${ride.timestamp.day}/${ride.timestamp.month}/${ride.timestamp.year} at ${ride.timestamp.hour}:${ride.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontSize: 12, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(ride.status).withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AdminDimensions.radiusSmall),
                    ),
                    child: Text(
                      ride.status.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(ride.status),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Route Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.radio_button_checked,
                          size: 16, color: AdminColors.success),
                      Container(
                          width: 2, height: 28, color: AdminColors.border),
                      const Icon(Icons.location_on,
                          size: 16, color: AdminColors.danger),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.pickupAddress,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          ride.destinationAddress,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Trip & Fare Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCol('Fare', '₹${ride.fare.toStringAsFixed(0)}',
                      isBold: true),
                  _buildMetricCol('Distance', '${ride.distanceKm} km'),
                  _buildMetricCol('Duration', '${ride.durationMins} mins'),
                  _buildMetricCol('Vehicle', ride.vehicleType),
                ],
              ),
              const Divider(height: 24),

              // Passenger & Captain Info
              _buildPartyTile(
                role: 'Passenger',
                name: ride.passengerName,
                phone: ride.passengerPhone,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 8),
              _buildPartyTile(
                role: 'Captain',
                name: ride.captainName ?? 'Not assigned yet',
                phone: ride.captainPhone ?? 'N/A',
                icon: Icons.two_wheeler_outlined,
              ),

              // Cancellation & Refund Details Card
              if (ride.isCancelled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminColors.dangerLight.withValues(alpha: 0.35),
                    borderRadius:
                        BorderRadius.circular(AdminDimensions.radiusSmall),
                    border: Border.all(
                        color: AdminColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            ride.isCancelledByCaptain
                                ? Icons.no_transfer_outlined
                                : Icons.person_off_outlined,
                            color: AdminColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cancelled by ${ride.cancelledBy?.toUpperCase() ?? 'USER'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.danger,
                            ),
                          ),
                          const Spacer(),
                          if (ride.cancelledAt != null)
                            Text(
                              '${ride.cancelledAt!.day}/${ride.cancelledAt!.month} ${ride.cancelledAt!.hour}:${ride.cancelledAt!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: ${ride.cancellationReason ?? 'No reason provided'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      if (ride.cancellationDescription != null &&
                          ride.cancellationDescription!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Notes: ${ride.cancellationDescription}',
                          style: const TextStyle(
                              fontSize: 12, color: AdminColors.textSecondary),
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cancellation Fee',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.textSecondary)),
                              Text(
                                (ride.cancellationFee != null &&
                                        ride.cancellationFee! > 0)
                                    ? '₹${ride.cancellationFee!.toStringAsFixed(0)}'
                                    : '₹0 (Waived)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: (ride.cancellationFee != null &&
                                          ride.cancellationFee! > 0)
                                      ? AdminColors.danger
                                      : AdminColors.success,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Refund Status',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.textSecondary)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (ride.refundStatus?.toUpperCase() ==
                                              'COMPLETED' ||
                                          (ride.refundAmount != null &&
                                              ride.refundAmount! > 0))
                                      ? AdminColors.successLight
                                      : AdminColors.warningLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ride.refundStatus?.toUpperCase() ??
                                      (ride.isRefunded
                                          ? 'COMPLETED'
                                          : 'NOT_APPLICABLE'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: (ride.refundStatus?.toUpperCase() ==
                                                'COMPLETED' ||
                                            (ride.refundAmount != null &&
                                                ride.refundAmount! > 0))
                                        ? AdminColors.success
                                        : AdminColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Refund Amount',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.textSecondary)),
                              Text(
                                '₹${(ride.refundAmount ?? 0.0).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (ride.refundId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Refund Reference: ${ride.refundId}',
                          style: const TextStyle(
                              fontSize: 11, color: AdminColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Manual Refund Action if eligible
              if (canProcessRefund) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showProcessRefundDialog(ride, matchingPayment);
                    },
                    icon: const Icon(Icons.currency_rupee, size: 16),
                    label: const Text('Process Admin Refund'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // View Ride Chat Log Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRideChatLogDialog(ride);
                  },
                  icon: const Icon(Icons.chat_outlined, size: 16, color: AdminColors.primary),
                  label: const Text('View Ride Chat Log', style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AdminColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRideChatLogDialog(AdminRideModel ride) {
    final chatService = AdminChatService();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.chat_outlined, color: AdminColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chat History • ${ride.id}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            height: 420,
            child: Column(
              children: [
                // Info Header
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rider: ${ride.passengerName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Captain: ${ride.captainName != null && ride.captainName!.isNotEmpty ? ride.captainName! : 'Not assigned'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Chat Messages Stream
                Expanded(
                  child: StreamBuilder<List<FirestoreChatMessageModel>>(
                    stream: chatService.streamMessages(ride.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
                      }

                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No chat messages recorded for this ride.',
                            style: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isUser = msg.isFromUser;
                          final isAdmin = msg.isFromAdmin;
                          final roleLabel = isAdmin ? 'ADMIN' : (isUser ? 'RIDER' : 'CAPTAIN');
                          final timeStr = '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? AdminColors.warningLight.withValues(alpha: 0.3)
                                  : (isUser ? AdminColors.background : AdminColors.primaryLight.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isAdmin
                                    ? AdminColors.warning
                                    : (isUser ? AdminColors.border : AdminColors.primary.withValues(alpha: 0.4)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${msg.senderName.isNotEmpty ? msg.senderName : roleLabel} ($roleLabel)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin ? AdminColors.warning : (isUser ? AdminColors.textPrimary : AdminColors.primary),
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.message,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Admin Note / Reply Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Post administrative note/message...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final text = messageCtrl.text.trim();
                        if (text.isEmpty) return;
                        messageCtrl.clear();
                        await chatService.sendAdminMessage(
                          rideId: ride.id,
                          adminId: 'admin_support_01',
                          adminName: 'QuickRide Support Admin',
                          message: text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: const Icon(Icons.send, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProcessRefundDialog(AdminRideModel ride, dynamic payment) {
    final fee = ride.cancellationFee ?? 0.0;
    final suggestedRefund =
        (payment.finalAmount - fee) > 0 ? (payment.finalAmount - fee) : 0.0;
    final refundAmountCtrl =
        TextEditingController(text: suggestedRefund.toStringAsFixed(0));
    final reasonCtrl = TextEditingController(
        text: 'Admin approved refund for cancelled ride ${ride.id}');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.currency_rupee, color: AdminColors.success),
            SizedBox(width: 8),
            Text('Issue Refund'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ride ID: ${ride.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Paid Amount: ₹${payment.finalAmount.toStringAsFixed(0)}',
                style: const TextStyle(color: AdminColors.textSecondary)),
            Text('Cancellation Fee Applied: ₹${fee.toStringAsFixed(0)}',
                style: const TextStyle(color: AdminColors.danger)),
            const SizedBox(height: 14),
            TextField(
              controller: refundAmountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Refund Amount (₹)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Refund',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final amount =
                  double.tryParse(refundAmountCtrl.text.trim()) ?? 0.0;
              final reason = reasonCtrl.text.trim();
              Navigator.pop(dialogCtx);

              final ok = await AdminStateService().refundPayment(
                payment.paymentId,
                reason: reason,
                refundAmount: amount,
                cancellationFee: fee,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Refund of ₹${amount.toStringAsFixed(0)} processed successfully!'
                        : 'Failed to process refund.'),
                    backgroundColor:
                        ok ? AdminColors.success : AdminColors.danger,
                  ),
                );
              }
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AdminColors.primary : AdminColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPartyTile({
    required String role,
    required String name,
    required String phone,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 18, color: AdminColors.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$role: $name',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(phone, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final adminState = AdminStateService();
        final rides = adminState.filterRides(
          query: _searchQuery,
          statusFilter: _statusFilter,
        );

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Inspect trip statuses, fares, passengers, cancellations and refunds',
                            style: TextStyle(
                                fontSize: 13, color: AdminColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rides.length} Trips',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Cancellation & Refund KPI Banner
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Total Cancelled',
                        '${adminState.totalCancellationsCount}',
                        Icons.cancel_outlined,
                        AdminColors.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'User Cancelled',
                        '${adminState.userCancellationsCount}',
                        Icons.person_off_outlined,
                        AdminColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'Capt Cancelled',
                        '${adminState.captainCancellationsCount}',
                        Icons.no_transfer_outlined,
                        AdminColors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'Refunds Processed',
                        '${adminState.totalRefundsCount} (₹${adminState.totalRefundsAmount.toStringAsFixed(0)})',
                        Icons.currency_rupee,
                        AdminColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText:
                        'Search by Ride ID, passenger, captain, or location...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: AdminDimensions.p12),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Statuses', null),
                      const SizedBox(width: 8),
                      _buildFilterChip('Requested', AdminRideStatus.requested),
                      const SizedBox(width: 8),
                      _buildFilterChip('Accepted', AdminRideStatus.accepted),
                      const SizedBox(width: 8),
                      _buildFilterChip('Arrived', AdminRideStatus.arrived),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'In Progress', AdminRideStatus.inProgress),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', AdminRideStatus.completed),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', AdminRideStatus.cancelled),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Rides List
                Expanded(
                  child: rides.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_car_outlined,
                                  size: 48, color: AdminColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'No rides match your filter criteria',
                                style:
                                    TextStyle(color: AdminColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: rides.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AdminDimensions.p8),
                          itemBuilder: (context, index) {
                            final ride = rides[index];
                            return Card(
                              child: InkWell(
                                onTap: () => _showRideDetailsModal(ride),
                                borderRadius: BorderRadius.circular(
                                    AdminDimensions.radiusMedium),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top info row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                ride.id,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          ride.status)
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  ride.status.label,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getStatusColor(
                                                        ride.status),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '₹${ride.fare.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AdminColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Route
                                      Row(
                                        children: [
                                          const Icon(Icons.circle,
                                              size: 8,
                                              color: AdminColors.success),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              ride.pickupAddress,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 10,
                                              color: AdminColors.danger),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              ride.destinationAddress,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Cancelled Banner
                                      if (ride.isCancelled) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AdminColors.dangerLight
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                                AdminDimensions.radiusSmall),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                ride.isCancelledByCaptain
                                                    ? Icons.no_transfer_outlined
                                                    : Icons.person_off_outlined,
                                                size: 13,
                                                color: AdminColors.danger,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Cancelled by ${ride.cancelledBy?.toUpperCase() ?? 'USER'}${ride.cancellationReason != null ? ' • ${ride.cancellationReason}' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AdminColors.danger,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (ride.refundAmount != null &&
                                                  ride.refundAmount! > 0) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Refund: ₹${ride.refundAmount!.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AdminColors.success,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],

                                      const Divider(height: 16),

                                      // Footer info
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rider: ${ride.passengerName} • Capt: ${ride.captainName ?? "Unassigned"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AdminColors.textSecondary,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${ride.distanceKm} km • ${ride.vehicleType}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AdminColors.textMuted,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                size: 16,
                                                color: AdminColors.textMuted,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AdminColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
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

  Widget _buildFilterChip(String label, AdminRideStatus? status) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _statusFilter = status);
      },
      backgroundColor: Colors.white,
      selectedColor: AdminColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AdminColors.primary : AdminColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
        side: BorderSide(
          color: isSelected ? AdminColors.primary : AdminColors.border,
        ),
      ),
    );
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
}
