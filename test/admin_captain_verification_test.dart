import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_captain_model.dart';
import 'package:quickride_admin/services/admin_state_service.dart';
import 'package:quickride_admin/screens/captains/admin_captains_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AdminStateService().resetMockData();
  });

  group('QuickRide Admin Step 42 Verification Model & State Tests', () {
    test('AdminCaptainModel verification properties and getters', () {
      final json = {
        'id': 'CPT-V1',
        'name': 'Ramesh Kumar',
        'phone': '9876543210',
        'email': 'ramesh@quickride.com',
        'vehicleNumber': 'KA-01-AB-1234',
        'vehicleType': 'Bajaj RE Auto',
        'licenseNumber': 'DL-KA0120200001234',
        'isOnline': false,
        'isActive': true,
        'rating': 4.8,
        'completedRides': 45,
        'joinedDate': '2026-01-10T10:00:00.000',
        'licenseDocUrl': 'https://example.com/license.jpg',
        'vehicleDocUrl': 'https://example.com/rc.jpg',
        'vehiclePhotoUrl': 'https://example.com/vehicle.jpg',
        'verificationStatus': 'PENDING',
        'vehicleVerificationStatus': 'PENDING',
        'documentsSubmittedAt': '2026-03-01T12:00:00.000',
      };

      final captain = AdminCaptainModel.fromJson(json);
      expect(captain.verificationStatus, 'PENDING');
      expect(captain.vehicleVerificationStatus, 'PENDING');
      expect(captain.isPending, isTrue);
      expect(captain.isApproved, isFalse);
      expect(captain.isRejected, isFalse);
      expect(captain.drivingLicenseImageUrl, 'https://example.com/license.jpg');
      expect(captain.vehicleDocumentImageUrl, 'https://example.com/rc.jpg');
      expect(captain.vehicleImage, 'https://example.com/vehicle.jpg');
      expect(captain.documentsSubmittedAt, isNotNull);
    });

    test('AdminStateService filterCaptains filters by verification status', () {
      final state = AdminStateService();

      final pendingCaptains = state.filterCaptains(verification: 'PENDING');
      expect(pendingCaptains.every((c) => c.verificationStatus == 'PENDING'), isTrue);

      final approvedCaptains = state.filterCaptains(verification: 'APPROVED');
      expect(approvedCaptains.every((c) => c.verificationStatus == 'APPROVED'), isTrue);

      final rejectedCaptains = state.filterCaptains(verification: 'REJECTED');
      expect(rejectedCaptains.every((c) => c.verificationStatus == 'REJECTED'), isTrue);

      final allCaptains = state.filterCaptains(verification: 'All');
      expect(allCaptains.length, greaterThanOrEqualTo(3));
    });

    test('AdminStateService approveCaptainVerification updates state and approval timestamp', () async {
      final state = AdminStateService();

      // Find a pending captain to approve
      final pending = state.filterCaptains(verification: 'PENDING').first;
      final success = await state.approveCaptainVerification(pending.id);
      expect(success, isTrue);

      final updated = state.captains.firstWhere((c) => c.id == pending.id);
      expect(updated.verificationStatus, 'APPROVED');
      expect(updated.vehicleVerificationStatus, 'APPROVED');
      expect(updated.verifiedAt, isNotNull);
      expect(updated.rejectionReason, isNull);
    });

    test('AdminStateService rejectCaptainVerification updates state with rejection reason', () async {
      final state = AdminStateService();

      // Find an approved or pending captain to reject
      final target = state.captains.first;
      const testReason = 'Documents expired and unreadable.';
      final success = await state.rejectCaptainVerification(target.id, testReason);
      expect(success, isTrue);

      final updated = state.captains.firstWhere((c) => c.id == target.id);
      expect(updated.verificationStatus, 'REJECTED');
      expect(updated.vehicleVerificationStatus, 'REJECTED');
      expect(updated.rejectionReason, testReason);
    });
  });

  group('QuickRide Admin Step 42 Verification UI & Dialog Tests', () {
    testWidgets('AdminCaptainsScreen displays verification filter and renders badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminCaptainsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verification dropdown filter is present
      expect(find.text('All Docs'), findsOneWidget);

      // Verify captain cards display verification badges
      expect(find.text('APPROVED'), findsWidgets);
      expect(find.text('PENDING'), findsWidgets);
    });

    testWidgets('AdminCaptainsScreen details dialog displays verification status, documents, and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminCaptainsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open details dialog for first captain
      final viewButton = find.byIcon(Icons.visibility_outlined).first;
      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      // Detail rows should include verification statuses
      expect(find.text('Verification Status'), findsOneWidget);
      expect(find.text('Vehicle Verification'), findsOneWidget);

      // Should have Close button
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('AdminCaptainsScreen rejection dialog validates reason and rejects captain', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminCaptainsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Filter by Pending Docs to get a pending captain
      await tester.tap(find.text('All Docs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pending Docs').last);
      await tester.pumpAndSettle();

      // Open details of pending captain
      final viewButton = find.byIcon(Icons.visibility_outlined).first;
      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      // Pending captain should show Approve and Reject action buttons
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      // Tap Reject button
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Rejection dialog should appear
      expect(find.textContaining('Reject Verification:'), findsOneWidget);
      expect(find.textContaining('Please provide a specific rejection reason'), findsOneWidget);

      // Enter reason and confirm
      await tester.enterText(find.byType(TextField).last, 'License expired on 2025-12-31');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm Rejection'));
      await tester.pumpAndSettle();

      // SnackBar confirmation
      expect(find.textContaining('rejected'), findsOneWidget);
    });
  });
}
