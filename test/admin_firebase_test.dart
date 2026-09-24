import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Firebase Integration Tests', () {
    test('AdminFirebaseService safe initialization and schema inspection', () async {
      final service = AdminFirebaseService();
      await service.initialize();
      expect(service.statusMessage.isNotEmpty, isTrue);

      final diag = await service.testConnection();
      expect(diag['appId'], 'com.quickride.admin');
      final collections = diag['managedCollections'] as List<String>;
      expect(collections, contains('users'));
      expect(collections, contains('captains'));
      expect(collections, contains('rides'));
      expect(collections, contains('complaints'));
      expect(collections, contains('ratings'));
      expect(collections, contains('offers'));
      expect(collections, contains('notifications'));
    });

    test('SharedRideModel parse in admin context', () {
      final ride = SharedRideModel(
        rideId: 'RD-ADMIN-1',
        userId: 'U-1',
        captainId: 'C-1',
        pickup: 'Point A',
        destination: 'Point B',
        pickupLocation: {'lat': 12.0, 'lng': 77.0},
        destinationLocation: {'lat': 12.1, 'lng': 77.1},
        vehicleType: 'Car',
        fare: 150.0,
        originalFare: 200.0,
        discountAmount: 50.0,
        offerId: 'OFF_1',
        couponCode: 'SAVE50',
        distance: 5.0,
        estimatedTime: 15,
        status: SharedRideStatus.inProgress,
        requestedAt: DateTime.now(),
      );

      final map = ride.toMap();
      final restored = SharedRideModel.fromMap(map);
      expect(restored.status, SharedRideStatus.inProgress);
      expect(restored.fare, 150.0);
      expect(restored.originalFare, 200.0);
      expect(restored.discountAmount, 50.0);
      expect(restored.offerId, 'OFF_1');
      expect(restored.couponCode, 'SAVE50');
    });

    test('FirestoreOfferModel serialization roundtrip in Admin app', () {
      final now = DateTime.now();
      final offer = FirestoreOfferModel(
        offerId: 'OFF_ADMIN_1',
        title: 'Festival Promo',
        description: 'Enjoy 30% off all festival rides',
        couponCode: 'FEST30',
        discountType: 'percentage',
        discountValue: 30.0,
        maxDiscount: 90.0,
        minimumFare: 120.0,
        validFrom: now.subtract(const Duration(days: 1)),
        validUntil: now.add(const Duration(days: 14)),
        usageLimit: 500,
        perUserLimit: 2,
        usedCount: 25,
        userUsage: {'usr_1': 1, 'usr_2': 2},
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = offer.toMap();
      final deserialized = FirestoreOfferModel.fromMap(map, id: 'OFF_ADMIN_1');

      expect(deserialized.offerId, 'OFF_ADMIN_1');
      expect(deserialized.couponCode, 'FEST30');
      expect(deserialized.discountValue, 30.0);
      expect(deserialized.maxDiscount, 90.0);
      expect(deserialized.minimumFare, 120.0);
      expect(deserialized.userUsage['usr_2'], 2);
      expect(deserialized.isValid, isTrue);

      final discount = deserialized.calculateDiscount(200.0);
      expect(discount, 60.0); // 30% of 200
    });
  });
}
