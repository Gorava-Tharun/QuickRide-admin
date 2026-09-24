import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../models/admin_user_model.dart';
import '../../services/admin_state_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'

  void _showUserDetailsDialog(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AdminColors.primary.withOpacity(0.12),
              backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
              child: user.profileImage == null
                  ? Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(user.id, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phone),
            _buildDetailRow('Total Rides', '${user.totalRides} trips'),
            _buildDetailRow(
              'Account Status',
              user.isActive ? 'Active' : 'Deactivated',
              valueColor: user.isActive ? AdminColors.success : AdminColors.danger,
            ),
            _buildDetailRow(
              'Member Since',
              '${user.joinedDate.day}/${user.joinedDate.month}/${user.joinedDate.year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              AdminStateService().toggleUserStatus(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    user.isActive
                        ? '${user.name} has been deactivated.'
                        : '${user.name} has been activated.',
                  ),
                  backgroundColor: user.isActive ? AdminColors.danger : AdminColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? AdminColors.danger : AdminColors.success,
            ),
            child: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
        final users = AdminStateService().filterUsers(
          query: _searchQuery,
          status: _statusFilter,
        );

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage registered riders, status, and activity',
                            style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${users.length} Users found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Search & Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name, phone, or email...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: AdminDimensions.p12),
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Status')),
                            DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminDimensions.p16),

                // Users List
                Expanded(
                  child: users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_rounded, size: 48, color: AdminColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'No users match your search criteria',
                                style: TextStyle(color: AdminColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AdminDimensions.p8),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: user.isActive
                                      ? AdminColors.primary.withOpacity(0.12)
                                      : AdminColors.danger.withOpacity(0.12),
                                  backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                                  child: user.profileImage == null
                                      ? Text(
                                          user.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: user.isActive ? AdminColors.primary : AdminColors.danger,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: user.isActive ? AdminColors.successLight : AdminColors.dangerLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user.isActive ? 'ACTIVE' : 'INACTIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: user.isActive ? AdminColors.success : AdminColors.danger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${user.phone} • ${user.email} • ${user.totalRides} trips',
                                    style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 20),
                                      tooltip: 'View User Details',
                                      onPressed: () => _showUserDetailsDialog(user),
                                    ),
                                    Switch(
                                      value: user.isActive,
                                      activeColor: AdminColors.success,
                                      onChanged: (_) {
                                        AdminStateService().toggleUserStatus(user.id);
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
