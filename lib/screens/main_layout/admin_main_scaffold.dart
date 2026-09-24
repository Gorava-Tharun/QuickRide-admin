import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_dimensions.dart';
import '../../core/constants/admin_strings.dart';
import '../../services/admin_state_service.dart';
import '../../services/admin_notification_service.dart';
import '../auth/admin_login_screen.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../users/admin_users_screen.dart';
import '../captains/admin_captains_screen.dart';
import '../rides/admin_rides_screen.dart';
import '../live_monitor/admin_live_rides_screen.dart';
import '../emergency/admin_emergency_screen.dart';
import '../complaints/admin_complaints_screen.dart';
import '../reviews/admin_reviews_screen.dart';
import '../reports/admin_reports_screen.dart';
import '../offers/admin_offers_screen.dart';
import '../payments/admin_payments_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../../widgets/admin_offline_banner.dart';

class AdminMainScaffold extends StatefulWidget {
  final int initialIndex;

  const AdminMainScaffold({super.key, this.initialIndex = 0});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  late int _selectedIndex;

  final List<String> _titles = [
    AdminStrings.navDashboard,
    AdminStrings.navUsers,
    AdminStrings.navCaptains,
    AdminStrings.navRides,
    AdminStrings.navLiveRides,
    AdminStrings.navEmergencies,
    AdminStrings.navComplaints,
    AdminStrings.navReviews,
    AdminStrings.navReports,
    AdminStrings.navOffers,
    AdminStrings.navPayments,
    AdminStrings.navSettings,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardScreen(onNavigate: _onSelectTab);
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminCaptainsScreen();
      case 3:
        return const AdminRidesScreen();
      case 4:
        return const AdminLiveRidesScreen();
      case 5:
        return const AdminEmergencyScreen();
      case 6:
        return const AdminComplaintsScreen();
      case 7:
        return const AdminReviewsScreen();
      case 8:
        return const AdminReportsScreen();
      case 9:
        return const AdminOffersScreen();
      case 10:
        return const AdminPaymentsScreen();
      case 11:
        return const AdminSettingsScreen();
      default:
        return AdminDashboardScreen(onNavigate: _onSelectTab);
    }
  }

  void _handleLogout() {
    AdminStateService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return ListenableBuilder(
          listenable: AdminNotificationService(),
          builder: (context, _) {
            final notifs = AdminNotificationService().notifications;
            final unread = AdminNotificationService().unreadCount;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AdminColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text('Notifications & Alerts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminColors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unread new',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminColors.danger),
                      ),
                    ),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: 420,
                child: notifs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 48, color: AdminColors.textMuted),
                            SizedBox(height: 12),
                            Text('No notifications', style: TextStyle(fontWeight: FontWeight.w600, color: AdminColors.textMuted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = notifs[i];
                          IconData icon = Icons.notifications_rounded;
                          Color iconColor = AdminColors.primary;

                          if (item.type == 'NEW_COMPLAINT' || item.type == 'URGENT_COMPLAINT' || item.type == 'COMPLAINT_REPLY') {
                            icon = Icons.support_agent_rounded;
                            iconColor = AdminColors.warning;
                          } else if (item.type == 'RIDE_CANCELLED') {
                            icon = Icons.cancel_outlined;
                            iconColor = AdminColors.danger;
                          } else if (item.type == 'PAYMENT_REFUNDED' || item.type == 'PAYMENT_SUCCESS') {
                            icon = Icons.payments_outlined;
                            iconColor = AdminColors.success;
                          } else if (item.type == 'EMERGENCY_ALERT' || item.type == 'EMERGENCY_STATUS') {
                            icon = Icons.emergency_rounded;
                            iconColor = AdminColors.danger;
                          }

                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: iconColor.withOpacity(0.12),
                              child: Icon(icon, color: iconColor, size: 18),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: item.read ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 13,
                                      color: item.read ? AdminColors.textPrimary : Colors.black,
                                    ),
                                  ),
                                ),
                                if (!item.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AdminColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(item.message, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10, color: AdminColors.textMuted),
                                ),
                              ],
                            ),
                            onTap: () {
                              AdminNotificationService().markAsRead(item.notificationId);
                              Navigator.of(dialogCtx).pop();

                              if (item.type == 'NEW_COMPLAINT' || item.type == 'URGENT_COMPLAINT' || item.type == 'COMPLAINT_REPLY') {
                                _onSelectTab(6); // Complaints
                              } else if (item.type == 'EMERGENCY_ALERT' || item.type == 'EMERGENCY_STATUS') {
                                _onSelectTab(5); // Safety & SOS
                              } else if (item.type == 'RIDE_CANCELLED' || item.type == 'RIDE_COMPLETED') {
                                _onSelectTab(3); // Rides
                              } else if (item.type == 'PAYMENT_REFUNDED' || item.type == 'PAYMENT_SUCCESS') {
                                _onSelectTab(10); // Payments & Escrow
                              }
                            },
                          );
                        },
                      ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => AdminNotificationService().markAllAsRead(),
                  child: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => AdminNotificationService().clearAll(),
                  child: const Text('Clear all', style: TextStyle(fontSize: 12, color: AdminColors.danger)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 12)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationBellButton() {
    return ListenableBuilder(
      listenable: AdminNotificationService(),
      builder: (context, _) {
        final unread = AdminNotificationService().unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AdminColors.textPrimary, size: 22),
              tooltip: 'Notifications',
              onPressed: () => _showNotificationsDialog(context),
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AdminColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AdminDimensions.mobileBreakpoint;

        if (isDesktop) {
          // Desktop / Tablet Sidebar Layout
          return Scaffold(
            body: Row(
              children: [
                // Fixed Sidebar
                Material(
                  color: AdminColors.sidebarBg,
                  child: SizedBox(
                    width: AdminDimensions.sidebarWidth,
                    child: Column(
                    children: [
                      // Sidebar Header / Brand
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    'assets/images/quickride_admin_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AdminStrings.appName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Command Center',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF334155), height: 1),

                      // Navigation Items List
                      Expanded(
                        child: ListenableBuilder(
                          listenable: AdminStateService(),
                          builder: (context, _) {
                            final activeSOS = AdminStateService().activeEmergenciesCount;
                            return ListView(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              children: [
                                _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                                _buildSidebarItem(1, Icons.people_outline_rounded, Icons.people_rounded, 'Users'),
                                _buildSidebarItem(2, Icons.two_wheeler_outlined, Icons.two_wheeler_rounded, 'Captains'),
                                _buildSidebarItem(3, Icons.local_taxi_outlined, Icons.local_taxi_rounded, 'Rides'),
                                _buildSidebarItem(4, Icons.radar_outlined, Icons.radar_rounded, 'Live Monitor'),
                                _buildSidebarItem(5, Icons.emergency_outlined, Icons.emergency_rounded, 'Safety & SOS', badgeCount: activeSOS),
                                _buildSidebarItem(6, Icons.support_agent_outlined, Icons.support_agent_rounded, 'Complaints'),
                                _buildSidebarItem(7, Icons.star_outline_rounded, Icons.star_rounded, 'Reviews'),
                                _buildSidebarItem(8, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Reports'),
                                _buildSidebarItem(9, Icons.local_offer_outlined, Icons.local_offer_rounded, 'Offers & Promos'),
                                _buildSidebarItem(10, Icons.payments_outlined, Icons.payments_rounded, 'Payments & Escrow'),
                                _buildSidebarItem(11, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
                              ],
                            );
                          },
                        ),
                      ),

                      // Sidebar Footer / Logout
                      const Divider(color: Color(0xFF334155), height: 1),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: const Icon(Icons.logout_rounded, color: AdminColors.danger),
                          title: const Text(
                            AdminStrings.logout,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: _handleLogout,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Desktop App Bar
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color: AdminColors.border)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _titles[_selectedIndex],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                _buildNotificationBellButton(),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AdminColors.background,
                                    borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                                    border: Border.all(color: AdminColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AdminColors.primary,
                                        child: Text(
                                          'A',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AdminStateService().adminEmail,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Offline Status Banner
                      const AdminOfflineBanner(),
                      // Screen Body
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Drawer & App Bar Layout
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              actions: [
                _buildNotificationBellButton(),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: AdminColors.sidebarBg,
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AdminColors.primary,
                              borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            AdminStrings.appName,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            AdminStrings.demoBadge,
                            style: TextStyle(color: AdminColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: AdminStateService(),
                      builder: (context, _) {
                        final activeSOS = AdminStateService().activeEmergenciesCount;
                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            _buildDrawerItem(0, Icons.dashboard_outlined, 'Dashboard'),
                            _buildDrawerItem(1, Icons.people_outline_rounded, 'Users'),
                            _buildDrawerItem(2, Icons.two_wheeler_outlined, 'Captains'),
                            _buildDrawerItem(3, Icons.local_taxi_outlined, 'Rides'),
                            _buildDrawerItem(4, Icons.radar_outlined, 'Live Monitor'),
                            _buildDrawerItem(5, Icons.emergency_outlined, 'Safety & SOS', badgeCount: activeSOS),
                            _buildDrawerItem(6, Icons.support_agent_outlined, 'Complaints'),
                            _buildDrawerItem(7, Icons.star_outline_rounded, 'Reviews'),
                            _buildDrawerItem(8, Icons.bar_chart_outlined, 'Reports'),
                            _buildDrawerItem(9, Icons.local_offer_outlined, 'Offers & Promos'),
                            _buildDrawerItem(10, Icons.payments_outlined, 'Payments & Escrow'),
                            _buildDrawerItem(11, Icons.settings_outlined, 'Settings'),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(color: Color(0xFF334155)),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AdminColors.danger),
                      title: const Text(
                        AdminStrings.logout,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: _handleLogout,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            body: Column(
              children: [
                const AdminOfflineBanner(),
                Expanded(child: _buildBody()),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, IconData activeIcon, String label, {int? badgeCount}) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? AdminColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          leading: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? Colors.white
                : (badgeCount != null && badgeCount > 0 ? AdminColors.danger : AdminColors.textMuted),
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          trailing: badgeCount != null && badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdminColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () => _onSelectTab(index),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label, {int? badgeCount}) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? AdminColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminDimensions.radiusSmall),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (badgeCount != null && badgeCount > 0 ? AdminColors.danger : AdminColors.textMuted),
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          trailing: badgeCount != null && badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdminColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            Navigator.pop(context); // Close drawer
            _onSelectTab(index);
          },
        ),
      ),
    );
  }
}
