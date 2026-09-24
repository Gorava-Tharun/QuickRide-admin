import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_captain_model.dart';
import '../../services/admin_state_service.dart';

class AdminCaptainsScreen extends StatefulWidget {
  const AdminCaptainsScreen({super.key});

  @override
  State<AdminCaptainsScreen> createState() => _AdminCaptainsScreenState();
}

class _AdminCaptainsScreenState extends State<AdminCaptainsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String _availabilityFilter = 'All'; // 'All', 'Online', 'Offline'
  String _verificationFilter = 'All'; // 'All', 'PENDING', 'APPROVED', 'REJECTED'

  void _showImagePreviewDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.all(32),
                  color: Colors.black87,
                  child: const Text('Unable to load document image',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(AdminCaptainModel captain) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.highlight_off_rounded,
                color: AdminColors.danger, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Reject Verification: ${captain.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a specific rejection reason so the captain can fix and re-upload their documents:',
              style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Driving license image is blurry or expired. Please upload a clear copy.',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? 'Documents do not meet platform verification standards.'
                  : reasonController.text.trim();
              Navigator.pop(ctx);
              await AdminStateService()
                  .rejectCaptainVerification(captain.id, reason);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${captain.name} verification rejected.'),
                    backgroundColor: AdminColors.danger,
                  ),
                );
              }
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  void _showCaptainDetailsDialog(AdminCaptainModel captain) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AdminColors.purple.withOpacity(0.12),
              backgroundImage: captain.profileImage != null
                  ? NetworkImage(captain.profileImage!)
                  : null,
              child: captain.profileImage == null
                  ? Text(
                      captain.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AdminColors.purple),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(captain.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(captain.id,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Phone', captain.phone),
                _buildDetailRow('Email', captain.email),
                _buildDetailRow('Vehicle',
                    '${captain.vehicleType} (${captain.vehicleNumber})'),
                _buildDetailRow('License No.', captain.licenseNumber),
                _buildDetailRow(
                  'Rating',
                  '★ ${captain.rating.toStringAsFixed(2)}',
                  valueColor: AdminColors.warning,
                ),
                _buildDetailRow(
                    'Completed Rides', '${captain.completedRides} rides'),
                _buildDetailRow(
                  'Duty Status',
                  captain.isOnline ? 'ONLINE' : 'OFFLINE',
                  valueColor: captain.isOnline
                      ? AdminColors.success
                      : AdminColors.secondary,
                ),
                _buildDetailRow(
                  'Account Status',
                  captain.isActive ? 'Active' : 'Suspended',
                  valueColor: captain.isActive
                      ? AdminColors.success
                      : AdminColors.danger,
                ),
                _buildDetailRow(
                  'Verification Status',
                  captain.verificationStatus,
                  valueColor: captain.isApproved
                      ? AdminColors.success
                      : (captain.isRejected
                          ? AdminColors.danger
                          : AdminColors.warning),
                ),
                _buildDetailRow(
                  'Vehicle Verification',
                  captain.vehicleVerificationStatus,
                  valueColor: captain.isApproved
                      ? AdminColors.success
                      : (captain.isRejected
                          ? AdminColors.danger
                          : AdminColors.warning),
                ),
                if (captain.documentsSubmittedAt != null)
                  _buildDetailRow(
                    'Submitted At',
                    '${captain.documentsSubmittedAt!.day}/${captain.documentsSubmittedAt!.month}/${captain.documentsSubmittedAt!.year}',
                  ),
                if (captain.verifiedAt != null)
                  _buildDetailRow(
                    'Verified At',
                    '${captain.verifiedAt!.day}/${captain.verifiedAt!.month}/${captain.verifiedAt!.year}',
                  ),
                _buildDetailRow(
                  'Joined Date',
                  '${captain.joinedDate.day}/${captain.joinedDate.month}/${captain.joinedDate.year}',
                ),

                if (captain.rejectionReason != null &&
                    captain.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminColors.dangerLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AdminColors.danger.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rejection Reason:',
                          style: TextStyle(
                              color: AdminColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          captain.rejectionReason!,
                          style: const TextStyle(
                              color: AdminColors.danger, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Text(
                  'Submitted Documents & Vehicle Photos',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (captain.drivingLicenseImageUrl != null)
                      _buildDocThumb(
                        label: 'Driving License',
                        url: captain.drivingLicenseImageUrl!,
                        onTap: () => _showImagePreviewDialog(
                            captain.drivingLicenseImageUrl!,
                            'Driving License: ${captain.name}'),
                      ),
                    if (captain.vehicleDocumentImageUrl != null)
                      _buildDocThumb(
                        label: 'Vehicle RC',
                        url: captain.vehicleDocumentImageUrl!,
                        onTap: () => _showImagePreviewDialog(
                            captain.vehicleDocumentImageUrl!,
                            'Vehicle RC Document: ${captain.name}'),
                      ),
                    if (captain.vehicleImage != null)
                      _buildDocThumb(
                        label: 'Vehicle Photo',
                        url: captain.vehicleImage!,
                        onTap: () => _showImagePreviewDialog(
                            captain.vehicleImage!,
                            'Vehicle Photo: ${captain.name}'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton(
            onPressed: () {
              AdminStateService().toggleCaptainStatus(captain.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    captain.isActive
                        ? '${captain.name} account suspended.'
                        : '${captain.name} account activated.',
                  ),
                  backgroundColor: captain.isActive
                      ? AdminColors.danger
                      : AdminColors.success,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  captain.isActive ? AdminColors.danger : AdminColors.success,
              side: BorderSide(
                  color: captain.isActive
                      ? AdminColors.danger
                      : AdminColors.success),
            ),
            child:
                Text(captain.isActive ? 'Suspend' : 'Activate'),
          ),
          if (!captain.isApproved) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.success),
              onPressed: () async {
                Navigator.pop(ctx);
                await AdminStateService()
                    .approveCaptainVerification(captain.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${captain.name} documents & vehicle verified!'),
                      backgroundColor: AdminColors.success,
                    ),
                  );
                }
              },
              child: const Text('Approve'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.danger),
              onPressed: () {
                Navigator.pop(ctx);
                _showRejectDialog(captain);
              },
              child: const Text('Reject'),
            ),
          ] else ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.danger,
                side: const BorderSide(color: AdminColors.danger),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showRejectDialog(captain);
              },
              child: const Text('Reject'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocThumb({
    required String label,
    required String url,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AdminColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                url,
                height: 75,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 75,
                  color: Colors.grey.shade200,
                  child: const Center(
                      child: Icon(Icons.broken_image_rounded, size: 24)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AdminColors.textPrimary,
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
        final captains = AdminStateService().filterCaptains(
          query: _searchQuery,
          status: _statusFilter,
          availability: _availabilityFilter,
          verification: _verificationFilter,
        );

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Captain Fleet Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Monitor drivers, vehicles, performance, and duty status',
                            style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${captains.length} Captains',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Search & Filters Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by captain name, phone, or vehicle number...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: AdminDimensions.p8),
                    // Availability Filter (Online/Offline)
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: DropdownButton<String>(
                          value: _availabilityFilter,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Duty')),
                            DropdownMenuItem(value: 'Online', child: Text('Online')),
                            DropdownMenuItem(value: 'Offline', child: Text('Offline')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _availabilityFilter = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminDimensions.p8),
                    // Account Status Filter (Active/Inactive)
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Status')),
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Suspended')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusFilter = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminDimensions.p8),
                    // Verification Status Filter
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: DropdownButton<String>(
                          value: _verificationFilter,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Docs')),
                            DropdownMenuItem(value: 'PENDING', child: Text('Pending Docs')),
                            DropdownMenuItem(value: 'APPROVED', child: Text('Approved Docs')),
                            DropdownMenuItem(value: 'REJECTED', child: Text('Rejected Docs')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _verificationFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Captains List
                Expanded(
                  child: captains.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sports_motorsports_outlined, size: 48, color: AdminColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'No captains match the selected criteria',
                                style: TextStyle(color: AdminColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: captains.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p8),
                          itemBuilder: (context, index) {
                            final captain = captains[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AdminColors.purple.withOpacity(0.12),
                                      backgroundImage: captain.profileImage != null ? NetworkImage(captain.profileImage!) : null,
                                      child: captain.profileImage == null
                                          ? const Icon(Icons.person, color: AdminColors.purple)
                                          : null,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: captain.isOnline ? AdminColors.success : Colors.grey,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      captain.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: captain.isOnline ? AdminColors.successLight : AdminColors.background,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: captain.isOnline ? AdminColors.success.withOpacity(0.4) : AdminColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        captain.isOnline ? 'ONLINE' : 'OFFLINE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: captain.isOnline ? AdminColors.success : AdminColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: captain.isActive ? AdminColors.successLight : AdminColors.dangerLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        captain.isActive ? 'ACTIVE' : 'SUSPENDED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: captain.isActive ? AdminColors.success : AdminColors.danger,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: captain.isApproved
                                            ? AdminColors.successLight
                                            : (captain.isRejected
                                                ? AdminColors.dangerLight
                                                : AdminColors.warningLight),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        captain.verificationStatus,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: captain.isApproved
                                              ? AdminColors.success
                                              : (captain.isRejected
                                                  ? AdminColors.danger
                                                  : AdminColors.warning),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 16, color: AdminColors.warning),
                                        const SizedBox(width: 2),
                                        Text(
                                          captain.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${captain.vehicleType} • ${captain.vehicleNumber} • ${captain.phone} • ${captain.completedRides} rides',
                                    style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 20),
                                      tooltip: 'View Captain Details',
                                      onPressed: () => _showCaptainDetailsDialog(captain),
                                    ),
                                    Switch(
                                      value: captain.isActive,
                                      activeColor: AdminColors.success,
                                      onChanged: (_) {
                                        AdminStateService().toggleCaptainStatus(captain.id);
                                      },
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
}
