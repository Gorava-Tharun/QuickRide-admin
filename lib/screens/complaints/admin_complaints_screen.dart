import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_complaint_model.dart';
import '../../models/firestore_models.dart';
import '../../services/admin_state_service.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ComplaintStatus? _selectedStatus;
  String _selectedRole = 'ALL'; // ALL, USER, CAPTAIN
  String _selectedPriority = 'ALL'; // ALL, URGENT, HIGH, NORMAL, LOW

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open:
        return AdminColors.danger;
      case ComplaintStatus.inReview:
        return AdminColors.warning;
      case ComplaintStatus.resolved:
        return AdminColors.success;
      case ComplaintStatus.closed:
        return AdminColors.secondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return AdminColors.danger;
      case 'HIGH':
        return Colors.deepOrange;
      case 'NORMAL':
        return AdminColors.primary;
      case 'LOW':
        return AdminColors.textSecondary;
      default:
        return AdminColors.textSecondary;
    }
  }

  void _showComplaintDetails(BuildContext context, AdminComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (ctx) => _ComplaintDetailsDialog(complaint: complaint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminStateService(),
      builder: (context, _) {
        final stateService = AdminStateService();
        final complaints = stateService.filterComplaints(
          status: _selectedStatus,
          role: _selectedRole,
          priority: _selectedPriority,
          searchQuery: _searchController.text,
        );

        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title & Summary Counters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complaints & Support',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Investigate grievances, manage priorities, and respond directly to riders and captains',
                            style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Quick Status Counters
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildMetricBadge('Total', '${stateService.totalComplaintsCount}', AdminColors.primary),
                        _buildMetricBadge('Open', '${stateService.openComplaintsCount}', AdminColors.danger),
                        _buildMetricBadge('In Review', '${stateService.inReviewComplaintsCount}', AdminColors.warning),
                        _buildMetricBadge('Urgent', '${stateService.urgentComplaintsCount}', Colors.deepOrange),
                        _buildMetricBadge('Resolved', '${stateService.resolvedComplaintsCount}', AdminColors.success),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Complainant Name, Ride ID, Payment ID, Subject...',
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
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMd),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminDimensions.radiusMd),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AdminDimensions.p12),

                // Filter Rows
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Role Filters
                      const Text('Role:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminColors.textSecondary)),
                      const SizedBox(width: 6),
                      _buildChoiceChip('All', _selectedRole == 'ALL', () => setState(() => _selectedRole = 'ALL')),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Riders', _selectedRole == 'USER', () => setState(() => _selectedRole = 'USER')),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Captains', _selectedRole == 'CAPTAIN', () => setState(() => _selectedRole = 'CAPTAIN')),

                      const SizedBox(width: 16),
                      const Text('|', style: TextStyle(color: AdminColors.border)),
                      const SizedBox(width: 16),

                      // Status Filters
                      const Text('Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminColors.textSecondary)),
                      const SizedBox(width: 6),
                      _buildChoiceChip('All', _selectedStatus == null, () => setState(() => _selectedStatus = null)),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Open', _selectedStatus == ComplaintStatus.open, () => setState(() => _selectedStatus = ComplaintStatus.open)),
                      const SizedBox(width: 4),
                      _buildChoiceChip('In Review', _selectedStatus == ComplaintStatus.inReview, () => setState(() => _selectedStatus = ComplaintStatus.inReview)),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Resolved', _selectedStatus == ComplaintStatus.resolved, () => setState(() => _selectedStatus = ComplaintStatus.resolved)),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Closed', _selectedStatus == ComplaintStatus.closed, () => setState(() => _selectedStatus = ComplaintStatus.closed)),

                      const SizedBox(width: 16),
                      const Text('|', style: TextStyle(color: AdminColors.border)),
                      const SizedBox(width: 16),

                      // Priority Filters
                      const Text('Priority:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminColors.textSecondary)),
                      const SizedBox(width: 6),
                      _buildChoiceChip('All', _selectedPriority == 'ALL', () => setState(() => _selectedPriority = 'ALL')),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Urgent', _selectedPriority == 'URGENT', () => setState(() => _selectedPriority = 'URGENT')),
                      const SizedBox(width: 4),
                      _buildChoiceChip('High', _selectedPriority == 'HIGH', () => setState(() => _selectedPriority = 'HIGH')),
                      const SizedBox(width: 4),
                      _buildChoiceChip('Normal', _selectedPriority == 'NORMAL', () => setState(() => _selectedPriority = 'NORMAL')),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Tickets List
                Expanded(
                  child: complaints.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                'No complaints match the selected filters',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try clearing your search query or changing filter parameters.',
                                style: TextStyle(fontSize: 12, color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: complaints.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p12),
                          itemBuilder: (context, index) {
                            final c = complaints[index];
                            final isCaptain = c.isCaptain;
                            final isUrgent = c.isUrgent;
                            final hasAttachment = c.attachmentUrl != null && c.attachmentUrl!.isNotEmpty;

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusMd),
                                side: BorderSide(
                                  color: isUrgent ? AdminColors.danger.withOpacity(0.5) : AdminColors.border,
                                  width: isUrgent ? 1.5 : 1.0,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusMd),
                                onTap: () => _showComplaintDetails(context, c),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Badges Row
                                      Row(
                                        children: [
                                          // Complainant Role Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isCaptain ? AdminColors.tealLight : AdminColors.primaryLight,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isCaptain ? Icons.two_wheeler_rounded : Icons.person_rounded,
                                                  size: 13,
                                                  color: isCaptain ? AdminColors.teal : AdminColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isCaptain ? 'CAPTAIN' : 'RIDER',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isCaptain ? AdminColors.teal : AdminColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Priority Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getPriorityColor(c.priority).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              c.priority.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getPriorityColor(c.priority),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Status Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(c.status).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              c.status.label,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(c.status),
                                              ),
                                            ),
                                          ),

                                          const Spacer(),

                                          // Attachment indicator
                                          if (hasAttachment)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.attach_file, size: 14, color: Colors.blueGrey.shade600),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'Photo',
                                                    style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          // Complaint ID & Date
                                          Text(
                                            c.id,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AdminColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${c.date.day}/${c.date.month}/${c.date.year}',
                                            style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Subject & Complainant Name
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.subject,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AdminColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  c.description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.chevron_right_rounded, color: AdminColors.textMuted),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Bottom Tags Row: Complainant details, Ride, Payment, Category
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          _buildTag(
                                            Icons.person_outline,
                                            isCaptain ? 'Captain: ${c.captainName}' : 'Rider: ${c.userName}',
                                          ),
                                          if (c.complainantPhone.isNotEmpty)
                                            _buildTag(Icons.phone_outlined, c.complainantPhone),
                                          if (c.rideId.isNotEmpty)
                                            _buildTag(Icons.directions_car_outlined, 'Ride: ${c.rideId}'),
                                          if (c.paymentId != null && c.paymentId!.isNotEmpty)
                                            _buildTag(Icons.receipt_long_outlined, 'Pay: ${c.paymentId}'),
                                          _buildTag(Icons.category_outlined, c.category.toUpperCase()),
                                          if (c.resolutionSummary != null && c.resolutionSummary!.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AdminColors.successLight,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.check, size: 12, color: AdminColors.success),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Resolved: ${c.resolutionSummary!}',
                                                    style: const TextStyle(fontSize: 10, color: AdminColors.success, fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
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

  Widget _buildMetricBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.9), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AdminColors.primary : AdminColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AdminColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AdminColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Detailed Complaint Inspector Dialog with real-time replies and resolution workflow
class _ComplaintDetailsDialog extends StatefulWidget {
  final AdminComplaintModel complaint;

  const _ComplaintDetailsDialog({required this.complaint});

  @override
  State<_ComplaintDetailsDialog> createState() => _ComplaintDetailsDialogState();
}

class _ComplaintDetailsDialogState extends State<_ComplaintDetailsDialog> {
  late AdminComplaintModel _current;
  late TextEditingController _notesController;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _repliesScrollController = ScrollController();
  bool _isSendingReply = false;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _current = widget.complaint;
    _notesController = TextEditingController(text: _current.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _replyController.dispose();
    _repliesScrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open:
        return AdminColors.danger;
      case ComplaintStatus.inReview:
        return AdminColors.warning;
      case ComplaintStatus.resolved:
        return AdminColors.success;
      case ComplaintStatus.closed:
        return AdminColors.secondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return AdminColors.danger;
      case 'HIGH':
        return Colors.deepOrange;
      case 'NORMAL':
        return AdminColors.primary;
      case 'LOW':
        return AdminColors.textSecondary;
      default:
        return AdminColors.textSecondary;
    }
  }

  void _showImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildImageErrorPlaceholder(),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildImageErrorPlaceholder(),
                      ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: 320,
      height: 240,
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Attachment preview unavailable', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _saveAdminNotes() async {
    setState(() => _isSavingNotes = true);
    await AdminStateService().updateComplaintStatus(
      _current.id,
      _current.status,
      adminNotes: _notesController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _isSavingNotes = false;
        _current = _current.copyWith(adminNotes: _notesController.text.trim());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin internal notes saved.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _changePriority(String newPriority) async {
    await AdminStateService().updateComplaintPriority(_current.id, newPriority);
    if (mounted) {
      setState(() {
        _current = _current.copyWith(priority: newPriority);
      });
    }
  }

  void _markInReview() async {
    await AdminStateService().updateComplaintStatus(
      _current.id,
      ComplaintStatus.inReview,
    );
    if (mounted) {
      setState(() {
        _current = _current.copyWith(status: ComplaintStatus.inReview);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket status changed to IN REVIEW.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _promptResolveComplaint() {
    final resController = TextEditingController(text: _current.resolutionSummary ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AdminColors.success),
            SizedBox(width: 8),
            Text('Resolve Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter resolution summary visible to the complainant:',
              style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: resController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Refund of ₹120 initiated. Captain warned for route deviation.',
                border: OutlineInputBorder(),
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
            onPressed: () async {
              final summary = resController.text.trim();
              if (summary.isEmpty) return;
              Navigator.pop(ctx);
              await AdminStateService().updateComplaintStatus(
                _current.id,
                ComplaintStatus.resolved,
                resolutionSummary: summary,
                adminNotes: _notesController.text.trim(),
              );
              if (mounted) {
                setState(() {
                  _current = _current.copyWith(
                    status: ComplaintStatus.resolved,
                    resolutionSummary: summary,
                    resolvedAt: DateTime.now(),
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint successfully marked as RESOLVED.'),
                    backgroundColor: AdminColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success),
            child: const Text('Confirm Resolution', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _closeComplaint() async {
    await AdminStateService().updateComplaintStatus(
      _current.id,
      ComplaintStatus.closed,
      adminNotes: _notesController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _current = _current.copyWith(status: ComplaintStatus.closed);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint has been closed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSendingReply) return;

    setState(() => _isSendingReply = true);
    final ok = await AdminStateService().sendComplaintReply(_current.id, text);
    if (mounted) {
      setState(() => _isSendingReply = false);
      if (ok) {
        _replyController.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_repliesScrollController.hasClients) {
            _repliesScrollController.animateTo(
              _repliesScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send response. Please try again.'),
            backgroundColor: AdminColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCaptain = _current.isCaptain;
    final hasAttachment = _current.attachmentUrl != null && _current.attachmentUrl!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 780,
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Column(
          children: [
            // Dialog Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AdminColors.border)),
              ),
              child: Row(
                children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCaptain ? AdminColors.tealLight : AdminColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCaptain ? Icons.two_wheeler_rounded : Icons.person_rounded,
                          size: 14,
                          color: isCaptain ? AdminColors.teal : AdminColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCaptain ? 'CAPTAIN DISPUTE' : 'RIDER COMPLAINT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCaptain ? AdminColors.teal : AdminColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _current.id,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                  ),
                  const Spacer(),
                  // Priority pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(_current.priority).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _current.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(_current.priority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_current.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _current.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_current.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close, color: AdminColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Complainant & Incident Meta Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isCaptain ? AdminColors.tealLight : AdminColors.primaryLight,
                                child: Icon(
                                  isCaptain ? Icons.two_wheeler_rounded : Icons.person_rounded,
                                  size: 18,
                                  color: isCaptain ? AdminColors.teal : AdminColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCaptain ? _current.captainName : _current.userName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${isCaptain ? 'Captain' : 'Rider'} • Phone: ${_current.complainantPhone.isNotEmpty ? _current.complainantPhone : 'Not provided'}',
                                      style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Filed: ${_current.date.day}/${_current.date.month}/${_current.date.year} ${_current.date.hour.toString().padLeft(2, '0')}:${_current.date.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CATEGORY: ${_current.category.toUpperCase()}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _current.subject,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _current.description,
                            style: const TextStyle(fontSize: 13, color: AdminColors.textPrimary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Attachment Preview (if any)
                    if (hasAttachment) ...[
                      const Text(
                        'Attachment Evidence',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showImageZoom(context, _current.attachmentUrl!),
                        child: Container(
                          width: 220,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AdminColors.border),
                            color: Colors.grey.shade100,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                _current.attachmentUrl!.startsWith('http')
                                    ? Image.network(
                                        _current.attachmentUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildImageErrorPlaceholder(),
                                      )
                                    : Image.asset(
                                        _current.attachmentUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildImageErrorPlaceholder(),
                                      ),
                                Container(
                                  width: double.infinity,
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.zoom_in, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tap to zoom photo',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Associated Entities (Ride & Payment Cards)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ride Ref Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.directions_car_rounded, size: 16, color: AdminColors.primary),
                                    SizedBox(width: 6),
                                    Text('Associated Ride', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Ride ID: ${_current.rideId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text('Other Party: ${isCaptain ? _current.userName : _current.captainName}',
                                    style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Payment Ref Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.receipt_long_rounded, size: 16, color: AdminColors.teal),
                                    SizedBox(width: 6),
                                    Text('Associated Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _current.paymentId != null && _current.paymentId!.isNotEmpty
                                      ? 'Payment ID: ${_current.paymentId}'
                                      : 'No direct payment linked',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _current.paymentId != null ? FontWeight.w600 : FontWeight.normal,
                                    color: _current.paymentId != null ? AdminColors.textPrimary : AdminColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Admin Actions & Resolution Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Administrative Controls',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                          ),
                          const SizedBox(height: 12),

                          // Priority Selector Row
                          Row(
                            children: [
                              const Text('Ticket Priority:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: _current.priority.toUpperCase(),
                                isDense: true,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 'LOW', child: Text('LOW')),
                                  DropdownMenuItem(value: 'NORMAL', child: Text('NORMAL')),
                                  DropdownMenuItem(value: 'HIGH', child: Text('HIGH')),
                                  DropdownMenuItem(value: 'URGENT', child: Text('URGENT (ESCALATED)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _changePriority(val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Admin Internal Notes Field
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Internal Admin Notes (Private)',
                              hintText: 'Add private staff investigation notes here...',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: _isSavingNotes
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save_outlined, color: AdminColors.primary),
                                tooltip: 'Save Note',
                                onPressed: _saveAdminNotes,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Resolution Summary Card (if already resolved)
                          if (_current.resolutionSummary != null && _current.resolutionSummary!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AdminColors.successLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AdminColors.success.withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: AdminColors.success),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Official Resolution',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminColors.success),
                                      ),
                                      const Spacer(),
                                      if (_current.resolvedAt != null)
                                        Text(
                                          '${_current.resolvedAt!.day}/${_current.resolvedAt!.month}/${_current.resolvedAt!.year}',
                                          style: const TextStyle(fontSize: 11, color: AdminColors.success),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _current.resolutionSummary!,
                                    style: const TextStyle(fontSize: 13, color: AdminColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),

                          // Status Change Actions Row
                          Row(
                            children: [
                              if (_current.status == ComplaintStatus.open)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.pending_actions, size: 16),
                                    label: const Text('Mark In Review'),
                                    onPressed: _markInReview,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AdminColors.warning,
                                      side: const BorderSide(color: AdminColors.warning),
                                    ),
                                  ),
                                ),
                              if (_current.status == ComplaintStatus.open) const SizedBox(width: 8),

                              if (_current.status != ComplaintStatus.resolved)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                                    label: const Text('Resolve Complaint', style: TextStyle(color: Colors.white)),
                                    onPressed: _promptResolveComplaint,
                                    style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success),
                                  ),
                                ),
                              if (_current.status != ComplaintStatus.resolved) const SizedBox(width: 8),

                              if (_current.status != ComplaintStatus.closed)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.lock_outline, size: 16),
                                  label: const Text('Close Ticket'),
                                  onPressed: _closeComplaint,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AdminColors.secondary,
                                    side: const BorderSide(color: AdminColors.border),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Real-Time Conversation / Reply Thread
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.forum_outlined, size: 18, color: AdminColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Support Conversation Thread',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Stream of replies
                          StreamBuilder<List<FirestoreComplaintReplyModel>>(
                            stream: AdminStateService().streamComplaintReplies(_current.id),
                            builder: (context, snapshot) {
                              final replies = snapshot.data ?? [];
                              if (replies.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'No messages exchanged yet. Send a response to the complainant below.',
                                    style: TextStyle(fontSize: 12, color: AdminColors.textMuted),
                                  ),
                                );
                              }

                              return ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 260),
                                child: ListView.separated(
                                  controller: _repliesScrollController,
                                  shrinkWrap: true,
                                  itemCount: replies.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final rep = replies[index];
                                    final isAdmin = rep.isAdmin;

                                    return Align(
                                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isAdmin ? AdminColors.primaryLight : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isAdmin ? AdminColors.primary.withOpacity(0.3) : AdminColors.border,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  rep.senderName.isNotEmpty ? rep.senderName : rep.senderRole,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isAdmin ? AdminColors.primary : AdminColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${rep.createdAt.hour.toString().padLeft(2, '0')}:${rep.createdAt.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              rep.message,
                                              style: const TextStyle(fontSize: 13, color: AdminColors.textPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const Divider(height: 24),

                          // Admin Reply Composer
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replyController,
                                  decoration: InputDecoration(
                                    hintText: 'Type response to ${isCaptain ? 'Captain' : 'Rider'}...',
                                    hintStyle: const TextStyle(fontSize: 13, color: AdminColors.textMuted),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AdminColors.border),
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendReply(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isSendingReply ? null : _sendReply,
                                icon: _isSendingReply
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                                label: const Text('Send', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ],
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
    );
  }
}

