import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_emergency_model.dart';
import '../../models/firestore_models.dart';
import '../../services/admin_state_service.dart';

class AdminEmergencyScreen extends StatefulWidget {
  const AdminEmergencyScreen({super.key});

  @override
  State<AdminEmergencyScreen> createState() => _AdminEmergencyScreenState();
}

class _AdminEmergencyScreenState extends State<AdminEmergencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  EmergencyStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.active:
        return AdminColors.danger;
      case EmergencyStatus.acknowledged:
        return AdminColors.warning;
      case EmergencyStatus.resolved:
        return AdminColors.success;
      case EmergencyStatus.closed:
        return AdminColors.secondary;
    }
  }

  void _showEmergencyDetails(BuildContext context, AdminEmergencyModel emergency) {
    showDialog(
      context: context,
      builder: (ctx) => _EmergencyDetailsDialog(emergency: emergency),
    );
  }

  void _quickAcknowledge(AdminEmergencyModel emergency) async {
    final success = await AdminStateService().acknowledgeEmergency(
      emergency.emergencyId,
      adminNotes: 'Alert acknowledged by dispatch desk at ${DateTime.now().toLocal()}',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Alert ${emergency.emergencyId} ACKNOWLEDGED by Desk'
                : 'Failed to acknowledge emergency alert.',
          ),
          backgroundColor: success ? AdminColors.warning : AdminColors.danger,
        ),
      );
    }
  }

  void _showResolveDialog(AdminEmergencyModel emergency) {
    final resolutionController = TextEditingController(text: 'Assistance dispatched and rider confirmed safe.');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AdminColors.success),
            const SizedBox(width: 8),
            Text('Resolve Incident ${emergency.emergencyId}'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provide resolution details for audit and historical record:',
                style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resolutionController,
                decoration: const InputDecoration(
                  labelText: 'Resolution Summary *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. PCR patrol reached location, rider safe.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Internal Admin Notes (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Internal logs, dispatch reference numbers...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success),
            icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
            label: const Text('Confirm Resolution', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final summary = resolutionController.text.trim();
              if (summary.isEmpty) return;
              Navigator.of(ctx).pop();
              final ok = await AdminStateService().resolveEmergency(
                emergency.emergencyId,
                resolutionSummary: summary,
                adminNotes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Incident ${emergency.emergencyId} marked as RESOLVED'
                          : 'Failed to resolve emergency incident.',
                    ),
                    backgroundColor: ok ? AdminColors.success : AdminColors.danger,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _quickClose(AdminEmergencyModel emergency) async {
    final ok = await AdminStateService().closeEmergency(
      emergency.emergencyId,
      adminNotes: 'Incident investigation archived and closed at ${DateTime.now().toLocal()}',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Incident ${emergency.emergencyId} CLOSED & Archived'
                : 'Failed to close incident.',
          ),
          backgroundColor: ok ? AdminColors.secondary : AdminColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final stateService = AdminStateService();
        final emergencies = stateService.filterEmergencies(
          status: _selectedStatus,
          searchQuery: _searchController.text,
        );

        final activeCount = stateService.activeEmergenciesCount;
        final ackCount = stateService.acknowledgedEmergenciesCount;
        final resCount = stateService.resolvedEmergenciesCount;
        final totalCount = stateService.totalEmergenciesCount;

        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Metrics
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    final headerInfo = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: activeCount > 0 ? AdminColors.danger.withOpacity(0.12) : AdminColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.emergency_rounded,
                                color: activeCount > 0 ? AdminColors.danger : AdminColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Safety & Emergency (SOS) Desk',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Real-time rider and captain SOS incidents, live telemetry on Google Maps, and authorized dispatch handling',
                          style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                        ),
                      ],
                    );

                    final badges = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMetricBadge('Active SOS', '$activeCount', AdminColors.danger, isUrgent: activeCount > 0),
                        _buildMetricBadge('Acknowledged', '$ackCount', AdminColors.warning),
                        _buildMetricBadge('Resolved/Closed', '$resCount', AdminColors.success),
                        _buildMetricBadge('Total', '$totalCount', AdminColors.primary),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerInfo,
                          const SizedBox(height: 12),
                          badges,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: headerInfo),
                        const SizedBox(width: 16),
                        badges,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Emergency ID, Ride ID, Rider/Captain Name, Phone, Plate...',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminColors.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AdminColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AdminDimensions.p12),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Incidents ($totalCount)', _selectedStatus == null, () {
                        setState(() => _selectedStatus = null);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Active SOS ($activeCount)',
                        _selectedStatus == EmergencyStatus.active,
                        () => setState(() => _selectedStatus = EmergencyStatus.active),
                        color: AdminColors.danger,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Acknowledged ($ackCount)',
                        _selectedStatus == EmergencyStatus.acknowledged,
                        () => setState(() => _selectedStatus = EmergencyStatus.acknowledged),
                        color: AdminColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Resolved',
                        _selectedStatus == EmergencyStatus.resolved,
                        () => setState(() => _selectedStatus = EmergencyStatus.resolved),
                        color: AdminColors.success,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Closed',
                        _selectedStatus == EmergencyStatus.closed,
                        () => setState(() => _selectedStatus = EmergencyStatus.closed),
                        color: AdminColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Incidents List
                Expanded(
                  child: emergencies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedStatus == EmergencyStatus.active
                                    ? Icons.security_rounded
                                    : Icons.inbox_outlined,
                                size: 54,
                                color: _selectedStatus == EmergencyStatus.active
                                    ? AdminColors.success
                                    : AdminColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedStatus == EmergencyStatus.active
                                    ? 'No Active SOS Alerts'
                                    : 'No emergency incidents found matching criteria',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedStatus == EmergencyStatus.active
                                    ? 'All rides are currently operating safely.'
                                    : 'Try resetting the search or status filters.',
                                style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: emergencies.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p12),
                          itemBuilder: (context, index) {
                            final em = emergencies[index];
                            final statusColor = _getStatusColor(em.status);

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                                side: BorderSide(
                                  color: em.isActive ? AdminColors.danger.withOpacity(0.8) : AdminColors.border,
                                  width: em.isActive ? 1.5 : 1,
                                ),
                              ),
                              color: em.isActive ? const Color(0xFFFFF1F2) : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(AdminDimensions.p16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: ID, status chip, triggered by, time
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                            border: Border.all(color: statusColor.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (em.isActive) ...[
                                                const Icon(Icons.warning_amber_rounded, size: 14, color: AdminColors.danger),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                em.statusLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          em.emergencyId,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AdminColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AdminColors.background,
                                            borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                            border: Border.all(color: AdminColors.border),
                                          ),
                                          child: Text(
                                            'Ride: ${em.rideId}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: em.triggeredBy.toUpperCase() == 'CAPTAIN'
                                                ? Colors.orange.withOpacity(0.12)
                                                : Colors.purple.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                          ),
                                          child: Text(
                                            'Triggered by: ${em.triggeredBy.toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: em.triggeredBy.toUpperCase() == 'CAPTAIN' ? Colors.orange[800] : Colors.purple[800],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.schedule, size: 14, color: AdminColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDateTime(em.createdAt),
                                          style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Row 2: Rider & Captain info
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Rider info
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: em.isActive ? Colors.white : AdminColors.background,
                                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                              border: Border.all(color: AdminColors.border),
                                            ),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: AdminColors.primaryLight,
                                                  child: Icon(Icons.person, size: 18, color: AdminColors.primary),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        em.userName,
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                      ),
                                                      Text(
                                                        em.userPhone.isNotEmpty ? em.userPhone : 'ID: ${em.userId}',
                                                        style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, size: 16, color: AdminColors.textMuted),
                                                  tooltip: 'Copy Phone',
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: em.userPhone));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Copied: ${em.userPhone}')),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Captain info
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: em.isActive ? Colors.white : AdminColors.background,
                                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                              border: Border.all(color: AdminColors.border),
                                            ),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: AdminColors.tealLight,
                                                  child: Icon(Icons.two_wheeler, size: 18, color: AdminColors.teal),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        em.captainName,
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                      ),
                                                      Text(
                                                        '${em.vehicleType} â€¢ ${em.vehicleNumber.isNotEmpty ? em.vehicleNumber : em.captainPhone}',
                                                        style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, size: 16, color: AdminColors.textMuted),
                                                  tooltip: 'Copy Phone',
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: em.captainPhone));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Copied: ${em.captainPhone}')),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Row 3: Route & Coordinates
                                    Row(
                                      children: [
                                        const Icon(Icons.trip_origin, size: 14, color: AdminColors.primary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Pickup: ${em.pickup}',
                                            style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.location_on, size: 14, color: AdminColors.danger),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Drop: ${em.destination}',
                                            style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AdminColors.border),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.my_location, size: 12, color: AdminColors.danger),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${em.latitude.toStringAsFixed(4)}, ${em.longitude.toStringAsFixed(4)}',
                                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Admin Notes / Resolution if any
                                    if (em.resolutionSummary != null && em.resolutionSummary!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AdminColors.success.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                          border: Border.all(color: AdminColors.success.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline, size: 16, color: AdminColors.success),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Resolution: ${em.resolutionSummary}',
                                                style: const TextStyle(fontSize: 12, color: AdminColors.success, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),

                                    // Action Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AdminColors.primary),
                                            foregroundColor: AdminColors.primary,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          icon: const Icon(Icons.map_outlined, size: 16),
                                          label: const Text('Inspect on Map & Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () => _showEmergencyDetails(context, em),
                                        ),
                                        Row(
                                          children: [
                                            if (em.isActive) ...[
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AdminColors.warning,
                                                  foregroundColor: Colors.black87,
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                ),
                                                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                                                label: const Text('Acknowledge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                onPressed: () => _quickAcknowledge(em),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            if (em.isActive || em.isAcknowledged) ...[
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AdminColors.success,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                ),
                                                icon: const Icon(Icons.check_circle_rounded, size: 16),
                                                label: const Text('Resolve Incident', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                onPressed: () => _showResolveDialog(em),
                                              ),
                                            ],
                                            if (em.isResolved) ...[
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AdminColors.secondary,
                                                  side: const BorderSide(color: AdminColors.secondary),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                ),
                                                icon: const Icon(Icons.archive_outlined, size: 16),
                                                label: const Text('Close & Archive', style: TextStyle(fontSize: 12)),
                                                onPressed: () => _quickClose(em),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
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

  Widget _buildMetricBadge(String label, String count, Color color, {bool isUrgent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? color.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        border: Border.all(color: isUrgent ? color : AdminColors.border, width: isUrgent ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUrgent) ...[
            Icon(Icons.warning_amber_rounded, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
          ),
          Text(
            count,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? AdminColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(AdminDimensions.radiusFull),
          border: Border.all(color: isSelected ? activeColor : AdminColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AdminColors.textPrimary,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _EmergencyDetailsDialog extends StatefulWidget {
  final AdminEmergencyModel emergency;

  const _EmergencyDetailsDialog({required this.emergency});

  @override
  State<_EmergencyDetailsDialog> createState() => _EmergencyDetailsDialogState();
}

class _EmergencyDetailsDialogState extends State<_EmergencyDetailsDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.emergency.adminNotes != null) {
      _notesController.text = widget.emergency.adminNotes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final em = widget.emergency;
    final emergencyPos = LatLng(em.latitude, em.longitude);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('emergency_pin'),
        position: emergencyPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: 'ðŸš¨ LIVE EMERGENCY LOCATION',
          snippet: 'Lat: ${em.latitude.toStringAsFixed(4)}, Lng: ${em.longitude.toStringAsFixed(4)}',
        ),
      ),
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminDimensions.radiusLarge)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 900,
        height: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: em.isActive ? AdminColors.danger.withOpacity(0.12) : AdminColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security_update_warning_rounded,
                    color: em.isActive ? AdminColors.danger : AdminColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Inspector â€” ${em.emergencyId}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ride #${em.rideId} â€¢ Triggered by ${em.triggeredBy} â€¢ Status: ${em.statusLabel}',
                        style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Body: Left Map, Right Details
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Google Map View
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: emergencyPos,
                              zoom: 15.0,
                            ),
                            markers: markers,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.gps_fixed, size: 12, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${em.latitude.toStringAsFixed(5)}, ${em.longitude.toStringAsFixed(5)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Side Details
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parties Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Party Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 8),
                                _buildDetailRow('Rider', '${em.userName} (${em.userPhone})'),
                                _buildDetailRow('Captain', '${em.captainName} (${em.captainPhone})'),
                                _buildDetailRow('Vehicle', '${em.vehicleType} â€¢ ${em.vehicleNumber}'),
                                _buildDetailRow('Pickup', em.pickup),
                                _buildDetailRow('Destination', em.destination),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Timestamps
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Timeline Audit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 8),
                                _buildDetailRow('Alert Triggered', em.createdAt.toLocal().toString()),
                                _buildDetailRow('Last Telemetry Update', em.updatedAt.toLocal().toString()),
                                if (em.resolvedAt != null)
                                  _buildDetailRow('Resolved At', em.resolvedAt!.toLocal().toString()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Resolution summary if resolved
                          if (em.resolutionSummary != null && em.resolutionSummary!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AdminColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                border: Border.all(color: AdminColors.success.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 14, color: AdminColors.success),
                                      SizedBox(width: 4),
                                      Text('Resolution Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AdminColors.success)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(em.resolutionSummary!, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Dispatch Guidance Notice
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Authorized Protocol: Verify rider location, contact emergency contacts if unresponsive, and coordinate with local emergency services (112) if critical.',
                                    style: TextStyle(fontSize: 11, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}