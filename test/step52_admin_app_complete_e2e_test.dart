import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/core/constants/admin_strings.dart';
import 'package:quickride_admin/core/errors/admin_error_handler.dart';
import 'package:quickride_admin/models/admin_complaint_model.dart';
import 'package:quickride_admin/models/admin_ride_model.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/screens/auth/admin_login_screen.dart';
import 'package:quickride_admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:quickride_admin/screens/main_layout/admin_main_scaffold.dart';
import 'package:quickride_admin/screens/reports/admin_reports_screen.dart';
import 'package:quickride_admin/services/admin_chat_service.dart';
import 'package:quickride_admin/services/admin_connectivity_service.dart';
import 'package:quickride_admin/services/admin_notification_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';
import 'package:quickride_admin/widgets/admin_offline_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 52: QuickRide Admin App Complete End-to-End Testing Suite', () {
    late AdminStateService stateService;
    late AdminConnectivityService connectivityService;

    setUp(() {
      stateService = AdminStateService();
      stateService.resetMockData();
      stateService.logout();

      connectivityService = AdminConnectivityService();
      connectivityService.setMockOnlineState(true);
    });

    tearDown(() {
      connectivityService.setMockOnlineState(true);
      stateService.logout();
      stateService.resetMockData();
    });

    // =========================================================================
    // 1. ADMIN LOGIN & SESSION PERSISTENCE
    // =========================================================================
    group('1. Admin Authentication & Session Management', () {
      testWidgets('AdminLoginScreen renders branding, demo credentials, and performs login', (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: AdminLoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AdminStrings.appName), findsOneWidget);
        expect(find.text(AdminStrings.demoBadge), findsOneWidget);
        expect(find.text('Login to Dashboard'), findsOneWidget);

        // Tap Login to Dashboard
        await tester.tap(find.text('Login to Dashboard'));
        await tester.pumpAndSettle();

        // Verify successful navigation to AdminMainScaffold
        expect(find.byType(AdminMainScaffold), findsOneWidget);
        expect(stateService.isLoggedIn, isTrue);
      });

      test('Admin authentication state transitions: login, fail, logout', () {
        expect(stateService.isLoggedIn, isFalse);

        // Invalid credentials
        final failed = stateService.login('invalid@gmail.com', '123');
        expect(failed, isFalse);
        expect(stateService.isLoggedIn, isFalse);

        // Valid admin login
        final success = stateService.login('admin@quickride.com', 'admin123');
        expect(success, isTrue);
        expect(stateService.isLoggedIn, isTrue);
        expect(stateService.adminEmail, 'admin@quickride.com');

        // Logout
        stateService.logout();
        expect(stateService.isLoggedIn, isFalse);
      });
    });

    // =========================================================================
    // 2. ADMIN DASHBOARD & REAL-TIME KPI METRICS
    // =========================================================================
    group('2. Admin Dashboard & Real-Time KPI Metrics', () {
      test('Dashboard Overview computes 8 real-time core metrics accurately', () {
        final overview = stateService.dashboardOverview;

        // 1. Total Users
        expect(overview.totalUsers, equals(stateService.totalUsersCount));
        expect(overview.totalUsers, greaterThan(0));

        // 2. Total Captains
        expect(overview.totalCaptains, equals(stateService.totalCaptainsCount));
        expect(overview.totalCaptains, greaterThan(0));

        // 3. Verified Captains
        expect(overview.verifiedCaptains, equals(stateService.verifiedCaptainsCount));
        expect(overview.verifiedCaptains, greaterThanOrEqualTo(0));

        // 4. Total Rides
        expect(overview.totalRides, equals(stateService.totalRidesCount));
        expect(overview.totalRides, greaterThan(0));

        // 5. Active Rides
        expect(overview.activeRides, equals(stateService.activeRidesCount));
        expect(overview.activeRides, greaterThanOrEqualTo(0));

        // 6. Completed Rides
        expect(overview.completedRides, equals(stateService.completedRidesCount));
        expect(overview.completedRides, greaterThan(0));

        // 7. Cancelled Rides
        expect(overview.cancelledRides, equals(stateService.cancelledRidesCount));
        expect(overview.cancelledRides, greaterThan(0));

        // 8. Total Revenue
        expect(overview.totalRevenue, equals(stateService.totalRevenue));
        expect(overview.totalRevenue, greaterThan(0));
      });

      test('Dashboard gracefully handles empty database without throwing', () {
        stateService.clearAllData();
        final emptyOverview = stateService.dashboardOverview;

        expect(emptyOverview.isEmpty, isTrue);
        expect(emptyOverview.totalUsers, 0);
        expect(emptyOverview.totalCaptains, 0);
        expect(emptyOverview.verifiedCaptains, 0);
        expect(emptyOverview.totalRides, 0);
        expect(emptyOverview.completedRides, 0);
        expect(emptyOverview.cancelledRides, 0);
        expect(emptyOverview.activeRides, 0);
        expect(emptyOverview.totalRevenue, 0.0);

        stateService.resetMockData();
      });

      testWidgets('AdminDashboardScreen renders all 8 KPI cards', (tester) async {
        int? tappedNav;

        await tester.pumpWidget(
          MaterialApp(
            home: AdminDashboardScreen(
              onNavigate: (idx) => tappedNav = idx,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Platform Overview'), findsOneWidget);
        expect(find.text('Total Users'), findsOneWidget);
        expect(find.text('Total Captains'), findsOneWidget);
        expect(find.text('Verified Captains'), findsOneWidget);
        expect(find.text('Total Rides'), findsOneWidget);
        expect(find.text('Completed Rides'), findsOneWidget);
        expect(find.text('Cancelled Rides'), findsOneWidget);
        expect(find.text('Active Rides'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);

        await tester.tap(find.text('Total Users'));
        expect(tappedNav, equals(1));
      });
    });

    // =========================================================================
    // 3. USER MANAGEMENT
    // =========================================================================
    group('3. User Management & Account Status', () {
      test('User search, filter and status toggling', () {
        expect(stateService.users.isNotEmpty, isTrue);

        // Filter by search query
        final found = stateService.filterUsers(query: 'Aarav');
        expect(found.length, 1);
        expect(found.first.name, 'Aarav Sharma');

        // Toggle user status
        final user = stateService.users.first;
        final originalStatus = user.isActive;
        stateService.toggleUserStatus(user.id);

        final updated = stateService.users.firstWhere((u) => u.id == user.id);
        expect(updated.isActive, !originalStatus);

        // Restore
        stateService.toggleUserStatus(user.id);
      });
    });

    // =========================================================================
    // 4. CAPTAIN MANAGEMENT
    // =========================================================================
    group('4. Captain Management & Fleet Status', () {
      test('Captain search, duty availability and account toggling', () {
        expect(stateService.captains.isNotEmpty, isTrue);

        // Filter by vehicle number
        final result = stateService.filterCaptains(query: 'KA 01');
        expect(result.isNotEmpty, isTrue);

        // Filter by online availability
        final onlineCaptains = stateService.filterCaptains(availability: 'Online');
        expect(onlineCaptains.every((c) => c.isOnline), isTrue);

        // Toggle captain active status
        final captain = stateService.captains.first;
        final originalActive = captain.isActive;
        stateService.toggleCaptainStatus(captain.id);

        final updated = stateService.captains.firstWhere((c) => c.id == captain.id);
        expect(updated.isActive, !originalActive);

        stateService.toggleCaptainStatus(captain.id);
      });
    });

    // =========================================================================
    // 5. VEHICLE & DOCUMENT VERIFICATION
    // =========================================================================
    group('5. Vehicle & Document Verification Workflow', () {
      test('Admin approves and rejects captain verification with timestamps and reasons', () async {
        // 1. Approval flow
        final pendingCaptains = stateService.filterCaptains(verification: 'PENDING');
        expect(pendingCaptains.isNotEmpty, isTrue);
        final targetPending = pendingCaptains.first;

        final approved = await stateService.approveCaptainVerification(targetPending.id);
        expect(approved, isTrue);

        final approvedCap = stateService.captains.firstWhere((c) => c.id == targetPending.id);
        expect(approvedCap.verificationStatus, 'APPROVED');
        expect(approvedCap.vehicleVerificationStatus, 'APPROVED');
        expect(approvedCap.verifiedAt, isNotNull);
        expect(approvedCap.rejectionReason, isNull);

        // 2. Rejection flow
        const reason = 'Vehicle RC image is blurred and expired.';
        final rejected = await stateService.rejectCaptainVerification(targetPending.id, reason);
        expect(rejected, isTrue);

        final rejectedCap = stateService.captains.firstWhere((c) => c.id == targetPending.id);
        expect(rejectedCap.verificationStatus, 'REJECTED');
        expect(rejectedCap.vehicleVerificationStatus, 'REJECTED');
        expect(rejectedCap.rejectionReason, reason);
      });
    });

    // =========================================================================
    // 6. RIDE MANAGEMENT
    // =========================================================================
    group('6. Ride Management & Details Filtering', () {
      test('Rides filtering by status and query returns matching records', () {
        expect(stateService.rides.isNotEmpty, isTrue);

        // Completed filter
        final completedRides = stateService.filterRides(statusFilter: AdminRideStatus.completed);
        expect(completedRides.every((r) => r.status == AdminRideStatus.completed), isTrue);

        // Cancelled filter
        final cancelledRides = stateService.filterRides(statusFilter: AdminRideStatus.cancelled);
        expect(cancelledRides.every((r) => r.status == AdminRideStatus.cancelled), isTrue);

        // Search query filter
        final queryResults = stateService.filterRides(query: 'Indiranagar');
        expect(queryResults.isNotEmpty, isTrue);
        expect(queryResults.every((r) =>
            r.pickupAddress.toLowerCase().contains('indiranagar') ||
            r.destinationAddress.toLowerCase().contains('indiranagar')), isTrue);
      });
    });

    // =========================================================================
    // 7. LIVE RIDE MONITORING
    // =========================================================================
    group('7. Live Ride Monitoring', () {
      test('Live rides getter identifies in-progress and accepted active rides', () {
        final live = stateService.liveRides;
        expect(live.isNotEmpty, isTrue);
        expect(live.every((r) =>
            r.status == AdminRideStatus.inProgress ||
            r.status == AdminRideStatus.accepted ||
            r.status == AdminRideStatus.arrived), isTrue);
      });
    });

    // =========================================================================
    // 8. PAYMENT & REVENUE REPORTS
    // =========================================================================
    group('8. Payment & Revenue Reports & Split Calculation', () {
      test('Revenue report computes 15% platform commission and 85% captain payout', () {
        final rev = stateService.revenueReportStats;

        expect(rev.totalGrossCollected, greaterThan(0));
        expect(rev.totalPlatformCommission, closeTo(rev.totalGrossCollected * 0.15, 0.01));
        expect(rev.totalCaptainEarnings, closeTo(rev.totalGrossCollected * 0.85, 0.01));
        expect(rev.totalPlatformCommission + rev.totalCaptainEarnings, closeTo(rev.totalGrossCollected, 0.01));
      });

      testWidgets('AdminReportsScreen switches between all 4 tabs cleanly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AdminReportsScreen(),
          ),
        );
        await tester.pump();

        expect(find.text('Platform Analytics & Reports'), findsOneWidget);
        expect(find.text('Revenue & Payments'), findsOneWidget);
        expect(find.text('Ride Analytics'), findsOneWidget);
        expect(find.text('User Reports'), findsOneWidget);
        expect(find.text('Captain & Fleet'), findsOneWidget);

        // Switch to Ride Analytics
        await tester.tap(find.text('Ride Analytics'));
        await tester.pumpAndSettle();
        expect(find.text('Rides by Vehicle Type: Bike, Auto, Car'), findsOneWidget);

        // Switch to User Reports
        await tester.tap(find.text('User Reports'));
        await tester.pumpAndSettle();
        expect(find.text('User Registration Statistics Over Time'), findsOneWidget);

        // Switch to Captain & Fleet
        await tester.tap(find.text('Captain & Fleet'));
        await tester.pumpAndSettle();
        expect(find.text('Top Performing Captains Leaderboard'), findsOneWidget);
      });
    });

    // =========================================================================
    // 9. COMPLAINTS & SUPPORT
    // =========================================================================
    group('9. Customer Support & Complaints Management', () {
      test('Complaint status transition and admin response workflow', () async {
        expect(stateService.complaints.isNotEmpty, isTrue);
        final complaint = stateService.complaints.first;

        // Update to inReview
        await stateService.updateComplaintStatus(
          complaint.id,
          ComplaintStatus.inReview,
          adminNotes: 'Reviewing trip logs.',
        );

        var updated = stateService.complaints.firstWhere((c) => c.id == complaint.id);
        expect(updated.status, ComplaintStatus.inReview);

        // Send reply
        final replyOk = await stateService.sendComplaintReply(
          complaint.id,
          'Your refund has been approved and processed.',
        );
        expect(replyOk, isTrue);

        // Update to resolved
        await stateService.updateComplaintStatus(
          complaint.id,
          ComplaintStatus.resolved,
          resolutionSummary: 'Refund processed successfully.',
        );

        updated = stateService.complaints.firstWhere((c) => c.id == complaint.id);
        expect(updated.status, ComplaintStatus.resolved);
      });
    });

    // =========================================================================
    // 10. RATINGS & REVIEWS
    // =========================================================================
    group('10. Ratings & Reviews Monitoring', () {
      test('Reviews list contains valid star ratings between 1 and 5', () {
        expect(stateService.reviews.isNotEmpty, isTrue);
        for (final r in stateService.reviews) {
          expect(r.rating, greaterThanOrEqualTo(1));
          expect(r.rating, lessThanOrEqualTo(5));
          expect(r.userName.isNotEmpty, isTrue);
        }
      });
    });

    // =========================================================================
    // 11. CHAT SUPPORT
    // =========================================================================
    group('11. In-Ride Chat Support Monitoring', () {
      test('AdminChatService sends administrative notes and fetches messages', () async {
        final chat = AdminChatService();
        chat.reset();

        const rideId = 'RIDE_ADM_AUDIT_101';
        final sent = await chat.sendAdminMessage(
          rideId: rideId,
          adminId: 'admin_support_01',
          adminName: 'QuickRide Safety Staff',
          message: 'Admin note: Verified passenger and captain location mismatch.',
        );
        expect(sent, isTrue);

        final messages = await chat.fetchMessages(rideId);
        expect(messages.length, 1);
        expect(messages.first.isFromAdmin, isTrue);
        expect(messages.first.senderRole, 'ADMIN');
      });
    });

    // =========================================================================
    // 12. NOTIFICATIONS
    // =========================================================================
    group('12. Admin Notifications', () {
      test('AdminNotificationService adds notification and marks read', () async {
        final notifService = AdminNotificationService();
        notifService.resetToDefault();

        final initialUnread = notifService.unreadCount;
        expect(initialUnread, greaterThan(0));

        final newNotif = FirestoreNotificationModel(
          notificationId: 'notif_adm_e2e_01',
          recipientId: 'admin_support_01',
          recipientRole: 'admin',
          title: 'New Emergency Alert',
          message: 'SOS triggered by Captain for ride REQ-101',
          type: 'EMERGENCY_ALERT',
          read: false,
          createdAt: DateTime.now(),
        );

        notifService.addNotification(newNotif);
        expect(notifService.notifications.first.notificationId, 'notif_adm_e2e_01');

        await notifService.markAsRead('notif_adm_e2e_01');
        final updated = notifService.notifications.firstWhere((n) => n.notificationId == 'notif_adm_e2e_01');
        expect(updated.read, isTrue);
      });
    });

    // =========================================================================
    // 13. SECURITY & ACCESS CONTROL
    // =========================================================================
    group('13. Security Rules & Admin Access Control', () {
      test('Security rules strictly forbid open read/write and enforce admin protection', () {
        final firestoreFile = File('../firestore.rules');
        final fallbackFirestoreFile = File('firestore.rules');
        final targetFirestore = firestoreFile.existsSync() ? firestoreFile : fallbackFirestoreFile;

        if (targetFirestore.existsSync()) {
          final rules = targetFirestore.readAsStringSync();
          expect(rules.contains('allow read, write: if true;'), isFalse);
          expect(rules.contains('function isAdmin()'), isTrue);
          expect(rules.contains('match /admins/{adminId}'), isTrue);
        }
      });
    });

    // =========================================================================
    // 14. OFFLINE RESILIENCY & ERROR HANDLING
    // =========================================================================
    group('14. Offline Resiliency & Error Translation', () {
      test('AdminErrorHandler maps exceptions to clear admin console messages', () {
        final socketMsg = AdminErrorHandler.getFriendlyErrorMessage(
          const SocketException('Connection reset'),
        );
        expect(socketMsg.contains('internet') || socketMsg.contains('network') || socketMsg.contains('offline'), isTrue);

        final timeoutMsg = AdminErrorHandler.getFriendlyErrorMessage(
          TimeoutException('Request timed out'),
        );
        expect(timeoutMsg.contains('time') || timeoutMsg.contains('slow') || timeoutMsg.contains('network'), isTrue);
      });

      test('Toggling network connectivity updates AdminConnectivityService', () {
        connectivityService.setMockOnlineState(false);
        expect(connectivityService.isOffline, isTrue);

        connectivityService.setMockOnlineState(true);
        expect(connectivityService.isOnline, isTrue);
      });

      testWidgets('AdminOfflineBanner displays warning only when offline', (tester) async {
        connectivityService.setMockOnlineState(false);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AdminOfflineBanner(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Admin Console Offline'), findsOneWidget);

        connectivityService.setMockOnlineState(true);
        await tester.pumpAndSettle();

        expect(find.textContaining('Admin Console Offline'), findsNothing);
      });
    });

    // =========================================================================
    // 15. PERFORMANCE & SETTINGS
    // =========================================================================
    group('15. System Settings & Commission Controls', () {
      test('System settings and commission rate update reactively', () {
        expect(stateService.commissionRate, 15.0);
        stateService.updateCommissionRate(20.0);
        expect(stateService.commissionRate, 20.0);

        expect(stateService.maintenanceMode, isFalse);
        stateService.toggleMaintenanceMode(true);
        expect(stateService.maintenanceMode, isTrue);
      });
    });
  });
}
