import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_captain_model.dart';
import 'package:quickride_admin/models/admin_user_model.dart';
import 'package:quickride_admin/screens/captains/admin_captains_screen.dart';
import 'package:quickride_admin/screens/users/admin_users_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickRide Admin Step 41 Profile Monitoring Unit & Model Tests', () {
    test('AdminCaptainModel correctly reads profilePhotoUrl and vehiclePhotoUrl', () {
      final json = {
        'id': 'CPT-999',
        'name': 'Captain Rajesh',
        'phone': '9876543210',
        'email': 'rajesh@quickride.com',
        'vehicleNumber': 'KA-05-HA-1234',
        'vehicleType': 'Honda Activa 6G (Bike)',
        'licenseNumber': 'DL-KA0520210009876',
        'isOnline': true,
        'isActive': true,
        'rating': 4.9,
        'completedRides': 148,
        'joinedDate': '2026-01-15T10:00:00.000',
        'profilePhotoUrl': 'https://example.com/profile.jpg',
        'vehiclePhotoUrl': 'https://example.com/vehicle.jpg',
      };

      final captain = AdminCaptainModel.fromJson(json);
      expect(captain.profileImage, 'https://example.com/profile.jpg');
      expect(captain.vehicleImage, 'https://example.com/vehicle.jpg');
    });

    test('AdminUserModel correctly reads profilePhotoUrl', () {
      final json = {
        'id': 'USR-101',
        'name': 'Aarav Sharma',
        'phone': '9845012345',
        'email': 'aarav@quickride.com',
        'isActive': true,
        'totalRides': 24,
        'joinedDate': '2026-02-01T10:00:00.000',
        'profilePhotoUrl': 'https://example.com/user.jpg',
      };

      final user = AdminUserModel.fromJson(json);
      expect(user.profileImage, 'https://example.com/user.jpg');
    });
  });

  group('QuickRide Admin Step 41 Profile Monitoring Dialogs', () {
    testWidgets('AdminCaptainsScreen displays details dialog with photos and without auth secrets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminCaptainsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find first visibility icon button
      final viewButton = find.byIcon(Icons.visibility_outlined).first;
      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      // Verify captain details are displayed
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Vehicle'), findsOneWidget);
      expect(find.text('License No.'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Duty Status'), findsOneWidget);

      // Verify no password or secret is exposed
      expect(find.textContaining('password', findRichText: true), findsNothing);
      expect(find.textContaining('secret', findRichText: true), findsNothing);
      expect(find.textContaining('token', findRichText: true), findsNothing);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('AdminUsersScreen displays details dialog with details and without auth secrets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminUsersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find first visibility icon button
      final viewButton = find.byIcon(Icons.visibility_outlined).first;
      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      // Verify user details are displayed
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Total Rides'), findsOneWidget);
      expect(find.text('Account Status'), findsOneWidget);
      expect(find.text('Member Since'), findsOneWidget);

      // Verify no password or secret is exposed
      expect(find.textContaining('password', findRichText: true), findsNothing);
      expect(find.textContaining('secret', findRichText: true), findsNothing);
      expect(find.textContaining('token', findRichText: true), findsNothing);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  });
}
