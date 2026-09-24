import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_report_model.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/screens/payments/admin_payments_screen.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 38: Admin Financial Reports & Reconciliation Tests', () {
    late AdminStateService service;

    setUp(() {
      service = AdminStateService();
    });

    test('15% platform commission and 85% captain payout calculations are accurate', () {
      final gross = service.totalGrossCollected;
      final platformCommission = service.totalPlatformCommission;
      final captainEarnings = service.totalCaptainEarnings;

      expect(gross, greaterThan(0));
      expect(platformCommission, closeTo(gross * 0.15, 0.01));
      expect(captainEarnings, closeTo(gross * 0.85, 0.01));
      expect(platformCommission + captainEarnings, closeTo(gross, 0.01));
    });

    test('Deduplication ensures only one paid payment per rideId is counted in revenue', () {
      final deduplicated = service.deduplicatedPaidPayments;
      final seen = <String>{};
      for (final p in deduplicated) {
        expect(p.paymentStatus, equals(FirestorePaymentStatus.paid));
        expect(seen.contains(p.rideId), isFalse, reason: 'Duplicate rideId found in deduplicated list');
        seen.add(p.rideId);
      }
    });

    test('Payment reconciliation detects anomalies accurately', () {
      final issues = service.reconciliationIssues;
      expect(issues, isNotEmpty);

      // Verify that cancelled ride RD-907 with paid payment is flagged
      final cancelledPaymentIssue = issues.where(
        (i) => i.type == ReconciliationIssueType.paidPaymentIncompleteRide && i.rideId == 'RD-907',
      );
      expect(cancelledPaymentIssue, isNotEmpty);
      expect(cancelledPaymentIssue.first.severity, equals('HIGH'));

      // Verify that completed ride RD-908 missing payment is flagged
      final missingPaymentIssue = issues.where(
        (i) => i.type == ReconciliationIssueType.completedRideUnpaid && i.rideId == 'RD-908',
      );
      expect(missingPaymentIssue, isNotEmpty);
      expect(missingPaymentIssue.first.severity, equals('HIGH'));
    });

    test('Administrative refund updates payment status to REFUNDED', () async {
      // Find a paid payment to test refund
      final target = service.payments.firstWhere(
        (p) => p.paymentStatus == FirestorePaymentStatus.paid && p.paymentId == 'PAY_RD_901',
      );

      final result = await service.refundPayment(target.paymentId, reason: 'Test customer refund');
      expect(result, isTrue);

      final updated = service.payments.firstWhere((p) => p.paymentId == target.paymentId);
      expect(updated.paymentStatus, equals(FirestorePaymentStatus.refunded));
      expect(updated.errorMessage, contains('Test customer refund'));
    });

    testWidgets('AdminPaymentsScreen renders all 3 tabs properly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdminPaymentsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Payment History & Financial Reports'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Financial Reports & 15% Split'), findsOneWidget);
      expect(find.text('Payment Reconciliation'), findsOneWidget);

      // Verify Tab 1 contents (Transactions table)
      expect(find.text('Total Collected'), findsOneWidget);
      expect(find.text('Successful Paid'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Switch to Tab 2: Financial Reports & 15% Split
      await tester.tap(find.text('Financial Reports & 15% Split'));
      await tester.pumpAndSettle();

      expect(find.text('Commission & Earnings Allocation Structure'), findsOneWidget);
      expect(find.text('85% Captains'), findsOneWidget);
      expect(find.text('15% Fee'), findsOneWidget);
      expect(find.text('Payment Method Volume Breakdown'), findsOneWidget);

      // Switch to Tab 3: Payment Reconciliation
      await tester.tap(find.text('Payment Reconciliation'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reconciliation Inconsistencies Detected'), findsOneWidget);
      expect(find.text('Re-Audit Now'), findsOneWidget);
    });
  });
}
