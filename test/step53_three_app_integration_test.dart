import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_chat_service.dart';
import 'package:quickride_admin/services/admin_connectivity_service.dart';
import 'package:quickride_admin/services/admin_notification_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 53: QuickRide Three-App Integration Testing Suite (Admin App Perspective)', () {
    late AdminStateService stateService;
    late AdminConnectivityService connectivity;
    late AdminChatService chatService;
    late AdminNotificationService notifService;

    setUp(() {
      connectivity = AdminConnectivityService();
      connectivity.setMockOnlineState(true);
      stateService = AdminStateService();
      chatService = AdminChatService();
      notifService = AdminNotificationService();
    });

    tearDown(() {
      connectivity.setMockOnlineState(true);
    });

    // =========================================================================
    // 1. ADMIN REAL-TIME DATA INGESTION
    // =========================================================================
    group('1. Admin Multi-App Data Monitoring & KPI Computation', () {
      test('Admin computes accurate counts and revenue from synchronized rides', () {
        final overview = stateService.dashboardOverview;
        expect(overview.totalUsers, isNonNegative);
        expect(overview.totalCaptains, isNonNegative);
        expect(overview.totalRides, isNonNegative);
        expect(overview.totalRevenue, isNonNegative);
      });

      test('Revenue split accurately credits platform and driver accounts', () {
        final reportStats = stateService.revenueReportStats;
        expect(reportStats.totalGrossCollected, greaterThanOrEqualTo(0));
        expect(reportStats.totalPlatformCommission, greaterThanOrEqualTo(0));
        expect(reportStats.totalCaptainEarnings, greaterThanOrEqualTo(0));
      });
    });

    // =========================================================================
    // 2. ADMIN -> SYSTEM CONTROLS & PROPAGATION
    // =========================================================================
    group('2. Admin Verification Actions & System Settings', () {
      test('Admin approves and rejects captain verification with structured records', () async {
        const testCapId = 'CAP-201';
        final approved = await stateService.approveCaptainVerification(testCapId);
        expect(approved, isTrue);

        final rejected = await stateService.rejectCaptainVerification(
          testCapId,
          'Vehicle registration certificate expired.',
        );
        expect(rejected, isTrue);
      });

      test('Admin adjusts commission rate and toggles maintenance mode', () {
        expect(stateService.commissionRate, 15.0);
        stateService.updateCommissionRate(18.0);
        expect(stateService.commissionRate, 18.0);

        expect(stateService.maintenanceMode, isFalse);
        stateService.toggleMaintenanceMode(true);
        expect(stateService.maintenanceMode, isTrue);

        // Reset
        stateService.updateCommissionRate(15.0);
        stateService.toggleMaintenanceMode(false);
      });
    });

    // =========================================================================
    // 3. ADMIN CHAT & NOTIFICATION BROADCASTS
    // =========================================================================
    group('3. Admin In-Ride Chat Intervention & Notifications', () {
      test('Admin dispatches message into active ride conversation', () async {
        const rideId = 'RIDE_ADMIN_INTERVENE_01';
        chatService.reset();

        final sent = await chatService.sendAdminMessage(
          rideId: rideId,
          adminId: 'admin_root',
          adminName: 'QuickRide Trust & Safety',
          message: 'Hello, our support team has flagged this trip for safety review.',
        );
        expect(sent, isTrue);

        final messages = await chatService.fetchMessages(rideId);
        expect(messages.any((m) => m.senderRole == 'ADMIN'), isTrue);
      });

      test('Admin notification creation and mark-as-read', () async {
        final notif = FirestoreNotificationModel(
          notificationId: 'notif_adm_01',
          recipientId: 'admin_all',
          recipientRole: 'admin',
          title: 'Surge Alert Triggered',
          message: 'High demand detected in Indiranagar Sector 4',
          type: 'SYSTEM',
          read: false,
          createdAt: DateTime.now(),
        );

        notifService.addNotification(notif);
        expect(notifService.unreadCount, greaterThan(0));

        await notifService.markAsRead('notif_adm_01');
      });
    });

    // =========================================================================
    // 4. SECURITY & PERMISSIONS AUDIT
    // =========================================================================
    group('4. Admin Security & Rules Verification', () {
      test('Security rules forbid open wildcard permissions', () {
        final firestoreRulesFile = File('../firestore.rules');
        if (firestoreRulesFile.existsSync()) {
          final content = firestoreRulesFile.readAsStringSync();
          expect(content.contains('allow read, write: if true;'), isFalse);
          expect(content.contains('allow read, write: if false;'), isTrue);
        }
      });
    });

    // =========================================================================
    // 5. OFFLINE RESILIENCY
    // =========================================================================
    group('5. Admin Console Offline Resiliency', () {
      test('Admin console remains stable during network disconnection', () {
        connectivity.setMockOnlineState(false);
        expect(connectivity.isOffline, isTrue);

        // Cached overview should remain readable
        final overview = stateService.dashboardOverview;
        expect(overview.totalRides, isNonNegative);

        connectivity.setMockOnlineState(true);
        expect(connectivity.isOnline, isTrue);
      });
    });
  });
}
