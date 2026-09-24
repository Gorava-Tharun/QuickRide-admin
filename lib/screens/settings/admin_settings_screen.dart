import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../services/admin_state_service.dart';
import '../auth/admin_login_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Admin Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin password updated successfully.'),
                  backgroundColor: AdminColors.success,
                ),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of QuickRide Admin Platform?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AdminStateService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            child: const Text('Logout'),
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
        final service = AdminStateService();

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminDimensions.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'System Settings & Administration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Global platform parameters, commission rate, and security credentials',
                  style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                ),
                const SizedBox(height: AdminDimensions.p20),

                // Admin Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AdminDimensions.p20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AdminColors.primary.withOpacity(0.12),
                          child: const Icon(Icons.security_rounded, size: 36, color: AdminColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.adminName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.adminEmail,
                                style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AdminColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  service.adminRole.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AdminColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AdminDimensions.p20),

                // App Platform Settings
                const Text(
                  'Platform Configuration',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                ),
                const SizedBox(height: AdminDimensions.p12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('System Maintenance Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Temporarily pauses all incoming rider booking requests'),
                        value: service.maintenanceMode,
                        activeColor: AdminColors.danger,
                        onChanged: (val) => service.toggleMaintenanceMode(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Platform Commission Rate', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Current take rate: ${service.commissionRate.toStringAsFixed(1)}% per ride'),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: service.commissionRate > 5.0
                                    ? () => service.updateCommissionRate(service.commissionRate - 1.0)
                                    : null,
                              ),
                              Text(
                                '${service.commissionRate.toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: service.commissionRate < 30.0
                                    ? () => service.updateCommissionRate(service.commissionRate + 1.0)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p20),

                // Notifications
                const Text(
                  'Notification Preferences',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                ),
                const SizedBox(height: AdminDimensions.p12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Critical System Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Server health alerts, outage triggers, and API errors'),
                        value: service.systemAlerts,
                        activeColor: AdminColors.primary,
                        onChanged: (val) => service.toggleSystemAlerts(val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Emergency Ride Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('SOS activations and urgent passenger safety notifications'),
                        value: service.rideAlerts,
                        activeColor: AdminColors.primary,
                        onChanged: (val) => service.toggleRideAlerts(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p20),

                // Security & Credentials
                const Text(
                  'Security & Authentication',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                ),
                const SizedBox(height: AdminDimensions.p12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Requires TOTP code verification on admin sign-in'),
                        value: service.twoFactorAuth,
                        activeColor: AdminColors.success,
                        onChanged: (val) => service.toggleTwoFactorAuth(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Change Administrator Password', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Update login credentials for super admin account'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: _showChangePasswordDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminDimensions.p24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text('Logout of Admin Console'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: AdminDimensions.p20),
              ],
            ),
          ),
        );
      },
    );
  }
}
