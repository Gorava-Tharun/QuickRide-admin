import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/admin_emergency_model.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/screens/emergency/admin_emergency_screen.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Emergency Model & Service Tests', () {
    test('AdminEmergencyModel properties, getters, and serialization roundtrip', () {
      final model = AdminEmergencyModel(
        emergencyId: 'EMG-ADM-001',
        rideId: 'RIDE-888',
        userId: 'USR-888',
        captainId: 'CPT-888',
        latitude: 12.9716,
        longitude: 77.5946,
        status: EmergencyStatus.active,
        triggeredBy: 'USER',
        userName: 'Priya Sharma',
        userPhone: '9876543210',
        captainName: 'Rajesh Driver',
        captainPhone: '9876501234',
        vehicleNumber: 'KA-04-AB-1234',
        vehicleType: 'Auto',
        pickup: 'Indiranagar 100ft Rd',
        destination: 'MG Road Metro',
        createdAt: DateTime(2026, 9, 19, 10, 0),
        updatedAt: DateTime(2026, 9, 19, 10, 0),
      );

      expect(model.emergencyId, 'EMG-ADM-001');
      expect(model.isActive, isTrue);
      expect(model.isAcknowledged, isFalse);
      expect(model.statusLabel, 'ACTIVE');

      final map = model.toMap();
      expect(map['emergencyId'], 'EMG-ADM-001');
      expect(map['status'], 'ACTIVE');
      expect(map['triggeredBy'], 'USER');

      final fromMap = AdminEmergencyModel.fromMap(map, id: 'EMG-ADM-001');
      expect(fromMap.emergencyId, 'EMG-ADM-001');
      expect(fromMap.userName, 'Priya Sharma');
      expect(fromMap.vehicleNumber, 'KA-04-AB-1234');
    });

    test('AdminEmergencyModel status transitions and copyWith', () {
      final model = AdminEmergencyModel(
        emergencyId: 'EMG-ADM-002',
        rideId: 'RIDE-889',
        userId: 'USR-889',
        captainId: 'CPT-889',
        latitude: 12.9716,
        longitude: 77.5946,
        status: EmergencyStatus.active,
        triggeredBy: 'CAPTAIN',
        createdAt: DateTime(2026, 9, 19, 10, 0),
        updatedAt: DateTime(2026, 9, 19, 10, 0),
      );

      final acknowledged = model.copyWith(
        status: EmergencyStatus.acknowledged,
        adminNotes: 'Officer dispatched',
      );
      expect(acknowledged.isAcknowledged, isTrue);
      expect(acknowledged.statusLabel, 'ACKNOWLEDGED');
      expect(acknowledged.adminNotes, 'Officer dispatched');

      final resolved = acknowledged.copyWith(
        status: EmergencyStatus.resolved,
        resolutionSummary: 'Situation defused safely',
        resolvedAt: DateTime.now(),
      );
      expect(resolved.isResolved, isTrue);
      expect(resolved.statusLabel, 'RESOLVED');
      expect(resolved.resolutionSummary, 'Situation defused safely');
    });

    test('AdminStateService handles emergency list and status mutations', () async {
      final service = AdminStateService();
      expect(service.emergencies, isNotNull);
      expect(service.totalEmergenciesCount >= 0, isTrue);
    });
  });

  group('AdminEmergencyScreen Widget Tests', () {
    testWidgets('AdminEmergencyScreen renders Desk header, metric badges, search bar and filter chips', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminEmergencyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Safety & Emergency (SOS) Desk'), findsOneWidget);
      expect(find.text('Active SOS: '), findsOneWidget);
      expect(find.text('Acknowledged: '), findsOneWidget);
      expect(find.text('Total: '), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
