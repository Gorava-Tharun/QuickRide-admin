import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_ride_model.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_state_service.dart';
import 'package:quickride_admin/screens/rides/admin_rides_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 43 — Admin Ride Model & Metrics Tests', () {
    test('AdminRideModel helper getters correctly identify cancellation sources and refunds', () {
      final userCancelledRide = AdminRideModel(
        id: 'RD-TEST-01',
        passengerName: 'Test Passenger',
        passengerPhone: '+91 99999 11111',
        pickupAddress: 'MG Road',
        destinationAddress: 'Koramangala',
        pickupLat: 12.9716,
        pickupLng: 77.5946,
        destLat: 12.9279,
        destLng: 77.6271,
        vehicleType: 'Bike',
        fare: 100.0,
        distanceKm: 5.0,
        durationMins: 15,
        status: AdminRideStatus.cancelled,
        timestamp: DateTime.now(),
        cancelledBy: 'user',
        cancellationReason: 'Driver delayed / waiting too long',
        cancellationFee: 25.0,
        refundAmount: 75.0,
        refundStatus: 'COMPLETED',
      );

      expect(userCancelledRide.isCancelled, isTrue);
      expect(userCancelledRide.isCancelledByUser, isTrue);
      expect(userCancelledRide.isCancelledByCaptain, isFalse);
      expect(userCancelledRide.isRefunded, isTrue);

      final captainCancelledRide = userCancelledRide.copyWith(
        id: 'RD-TEST-02',
        cancelledBy: 'captain',
        cancellationReason: 'Vehicle breakdown',
        cancellationFee: 0.0,
        refundAmount: 100.0,
      );

      expect(captainCancelledRide.isCancelled, isTrue);
      expect(captainCancelledRide.isCancelledByUser, isFalse);
      expect(captainCancelledRide.isCancelledByCaptain, isTrue);
      expect(captainCancelledRide.isRefunded, isTrue);
    });

    test('AdminStateService cancellation and refund metric counters accurately reflect mock data', () {
      final state = AdminStateService();

      expect(state.totalCancellationsCount, greaterThan(0));
      expect(state.userCancellationsCount, greaterThan(0));
      expect(state.captainCancellationsCount, greaterThan(0));
      expect(state.totalCancellationsCount,
          greaterThanOrEqualTo(state.userCancellationsCount + state.captainCancellationsCount));
      expect(state.totalRefundsCount, greaterThan(0));
      expect(state.totalRefundsAmount, greaterThan(0.0));
    });

    test('AdminStateService.refundPayment successfully issues refund and deducts cancellation fee', () async {
      final state = AdminStateService();

      // Look for a payment that is not refunded
      final paidPayment = state.payments
          .firstWhere((p) => p.paymentStatus == FirestorePaymentStatus.paid);

      final success = await state.refundPayment(
        paidPayment.paymentId,
        reason: 'Passenger dispute resolution',
        cancellationFee: 25.0,
        refundAmount: paidPayment.finalAmount - 25.0,
      );

      expect(success, isTrue);

      // Verify the payment was updated to refunded
      final updated = state.payments
          .firstWhere((p) => p.paymentId == paidPayment.paymentId);
      expect(updated.paymentStatus, FirestorePaymentStatus.refunded);
      expect(updated.refundAmount, paidPayment.finalAmount - 25.0);
      expect(updated.cancellationFee, 25.0);
      expect(updated.refundReason, 'Passenger dispute resolution');
      expect(updated.refundId, isNotNull);
      expect(updated.refundedAt, isNotNull);
    });
  });

  group('Step 43 — AdminRidesScreen UI Tests', () {
    testWidgets('AdminRidesScreen displays cancellation and refund KPI metrics and filter chips', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminRidesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Ride Management'), findsOneWidget);
      expect(find.textContaining('cancellations and refunds'), findsOneWidget);

      // Check KPI Cards
      expect(find.text('Total Cancelled'), findsOneWidget);
      expect(find.text('User Cancelled'), findsOneWidget);
      expect(find.text('Capt Cancelled'), findsOneWidget);
      expect(find.text('Refunds Processed'), findsOneWidget);

      // Check Filter Chips
      expect(find.text('All Statuses'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Tap Cancelled chip
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();

      // Verify cancelled badge in list item
      expect(find.textContaining('Cancelled by'), findsWidgets);
    });
  });
}
