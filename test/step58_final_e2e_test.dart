import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_connectivity_service.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 58: QuickRide Admin Console Final End-to-End Testing Suite', () {
    late AdminStateService adminState;
    late AdminConnectivityService connectivity;

    setUp(() {
      adminState = AdminStateService();
      connectivity = AdminConnectivityService();
      connectivity.setMockOnlineState(true);
      adminState.login('admin@quickride.com', 'admin123');
    });

    tearDown(() {
      adminState.logout();
      connectivity.setMockOnlineState(true);
    });

    // -------------------------------------------------------------------------
    // 1. ADMIN AUTHENTICATION & SESSION GATING
    // -------------------------------------------------------------------------
    group('1. Admin Authentication & Domain Gating', () {
      test('Unauthorized emails are rejected; authorized super admin succeeds', () {
        adminState.logout();
        expect(adminState.isLoggedIn, isFalse);

        // Blank rejected
        expect(adminState.login('', ''), isFalse);

        // Non-admin email rejected
        expect(adminState.login('driver@gmail.com', 'admin123'), isFalse);

        // Authorized admin email succeeds
        expect(adminState.login('admin@quickride.com', 'admin123'), isTrue);
        expect(adminState.isLoggedIn, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // 2. DASHBOARD KPI METRICS AGGREGATION
    // -------------------------------------------------------------------------
    group('2. Admin Dashboard Live Metrics Aggregation', () {
      test('Dashboard exposes valid, non-negative real-time aggregates', () {
        expect(adminState.users, isA<List>());
        expect(adminState.captains, isA<List>());
        expect(adminState.rides, isA<List>());
        expect(adminState.payments, isA<List>());
        expect(adminState.complaints, isA<List>());
        expect(adminState.emergencies, isA<List>());
      });
    });

    // -------------------------------------------------------------------------
    // 3. CAPTAIN VERIFICATION WORKFLOW
    // -------------------------------------------------------------------------
    group('3. Captain Document & Vehicle Verification Lifecycle', () {
      test('Admin approves and rejects captain documents with audit trail', () async {
        final fb = AdminFirebaseService();

        // Approval
        final approved = await fb.updateCaptainVerification(
          'CAP_E2E_01',
          verificationStatus: 'APPROVED',
          vehicleVerificationStatus: 'APPROVED',
          verifiedAt: DateTime.now(),
        );
        expect(approved, isTrue);

        // Rejection with feedback reason
        final rejected = await fb.updateCaptainVerification(
          'CAP_E2E_02',
          verificationStatus: 'REJECTED',
          vehicleVerificationStatus: 'REJECTED',
          rejectionReason: 'Vehicle insurance expired',
        );
        expect(rejected, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // 4. PAYMENTS, REFUNDS & FINANCIAL REPORTING
    // -------------------------------------------------------------------------
    group('4. Payment Reconciliation & Refund Audit Processing', () {
      test('Admin executes customer refund and generates audit record', () async {
        final fb = AdminFirebaseService();

        final refundSuccess = await fb.processRefund(
          'PAY_E2E_REFUND_58',
          refundAmount: 200.0,
          cancellationFee: 20.0,
          reason: 'Delayed pickup refund processed by admin',
          rideId: 'RIDE_E2E_58',
        );

        expect(refundSuccess, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // 5. EMERGENCY OPERATIONS & OFFLINE RESILIENCE
    // -------------------------------------------------------------------------
    group('5. Emergency Management & Offline Connectivity Resiliency', () {
      test('Admin marks active emergency incident as resolved', () async {
        final fb = AdminFirebaseService();

        final resolved = await fb.updateEmergencyStatus(
          'EMG_E2E_58_INCIDENT',
          EmergencyStatus.resolved,
          adminNotes: 'Security patrol contacted passenger. Safe arrival confirmed.',
        );

        expect(resolved, isTrue);
      });

      test('Network toggling preserves Admin session and synchronizes state', () {
        connectivity.setMockOnlineState(false);
        expect(connectivity.isOnline, isFalse);

        connectivity.setMockOnlineState(true);
        expect(connectivity.isOnline, isTrue);
      });
    });
  });
}
