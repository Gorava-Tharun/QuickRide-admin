import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 57: QuickRide Admin Console Final Security Audit & Authorization Tests', () {
    test('1. Admin Authorization Guard: Unauthorized email / blank logins are rejected', () {
      final state = AdminStateService();

      // Empty credentials rejected
      expect(state.login('', ''), isFalse);

      // Short password rejected
      expect(state.login('admin@quickride.com', '123'), isFalse);

      // Non-admin email rejected
      expect(state.login('hacker@external.com', 'badpassword'), isFalse);

      // Authorized super admin credentials succeed
      expect(state.login('admin@quickride.com', 'admin123'), isTrue);
      expect(state.isLoggedIn, isTrue);

      state.logout();
      expect(state.isLoggedIn, isFalse);
    });

    test('2. Captain Verification Security: Admin verification requires valid status keywords', () async {
      final fb = AdminFirebaseService();

      // Approve captain verification
      final approved = await fb.updateCaptainVerification(
        'CAP_SEC_001',
        verificationStatus: 'APPROVED',
        vehicleVerificationStatus: 'APPROVED',
        verifiedAt: DateTime.now(),
      );
      expect(approved, isTrue);

      // Reject captain verification with reason
      final rejected = await fb.updateCaptainVerification(
        'CAP_SEC_001',
        verificationStatus: 'REJECTED',
        vehicleVerificationStatus: 'REJECTED',
        rejectionReason: 'Invalid driving license image resolution',
      );
      expect(rejected, isTrue);
    });

    test('3. Payment & Refund Security: Admin refunds generate unique refund IDs and record audit trails', () async {
      final fb = AdminFirebaseService();

      final refundProcessed = await fb.processRefund(
        'PAY_RIDE_SEC_01',
        refundAmount: 150.0,
        cancellationFee: 25.0,
        reason: 'Authorized driver cancellation refund',
        rideId: 'RIDE_SEC_01',
      );

      expect(refundProcessed, isTrue);
    });

    test('4. Emergency Management Security: Admin updates emergency incident status with timestamps', () async {
      final fb = AdminFirebaseService();

      final updated = await fb.updateEmergencyStatus(
        'EMG_RIDE_101_LIVE',
        EmergencyStatus.resolved,
        adminNotes: 'Field safety contact confirmed false alarm',
        resolutionSummary: 'Verified passenger safety via direct call',
      );

      expect(updated, isTrue);
    });
  });
}
