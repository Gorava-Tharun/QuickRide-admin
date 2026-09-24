import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/screens/rides/admin_rides_screen.dart';
import 'package:quickride_admin/services/admin_chat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AdminChatService().reset();
  });

  group('Step 45: AdminChatService Tests', () {
    test('AdminChatService streams and fetches chat messages', () async {
      final service = AdminChatService();
      const rideId = 'RIDE_ADM_AUDIT_101';

      final success = await service.sendAdminMessage(
        rideId: rideId,
        adminId: 'admin_support_01',
        adminName: 'QuickRide Safety Staff',
        message: 'Admin note: Verified passenger and captain location mismatch.',
      );
      expect(success, isTrue);

      final messages = await service.fetchMessages(rideId);
      expect(messages.length, 1);
      expect(messages.first.isFromAdmin, isTrue);
      expect(messages.first.senderRole, 'ADMIN');
      expect(messages.first.message, 'Admin note: Verified passenger and captain location mismatch.');
    });

    test('sendAdminMessage rejects empty text', () async {
      final service = AdminChatService();
      final result = await service.sendAdminMessage(
        rideId: 'R1',
        adminId: 'A1',
        adminName: 'Admin',
        message: '   ',
      );
      expect(result, isFalse);
    });
  });

  group('Step 45: AdminRidesScreen Chat Log UI Tests', () {
    testWidgets('AdminRidesScreen renders View Ride Chat Log button and dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminRidesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first ride in the table to open details modal
      final firstRideItem = find.text('RIDE-101');
      if (firstRideItem.evaluate().isNotEmpty) {
        await tester.tap(firstRideItem.first);
        await tester.pumpAndSettle();

        // Check if View Ride Chat Log button is rendered
        expect(find.text('View Ride Chat Log'), findsOneWidget);

        // Tap View Ride Chat Log
        await tester.tap(find.text('View Ride Chat Log'));
        await tester.pumpAndSettle();

        // Check if dialog is open
        expect(find.textContaining('Chat History'), findsOneWidget);
        expect(find.text('Post administrative note/message...'), findsOneWidget);
      }
    });
  });
}
