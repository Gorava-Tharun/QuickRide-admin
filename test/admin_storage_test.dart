import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/services/admin_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Storage Service Tests', () {
    test('AdminStorageService singleton instance is consistent', () {
      final s1 = AdminStorageService();
      final s2 = AdminStorageService();
      expect(identical(s1, s2), isTrue);
    });

    test('getUserProfileImageUrl returns fallback URL when offline', () async {
      final service = AdminStorageService();
      final url = await service.getUserProfileImageUrl('user-999');
      expect(url, isNotNull);
      expect(url, contains('images.unsplash.com'));
    });

    test('getCaptainProfileImageUrl and getCaptainVehicleImageUrl return fallbacks when offline', () async {
      final service = AdminStorageService();
      final profileUrl = await service.getCaptainProfileImageUrl('cpt-101');
      final vehicleUrl = await service.getCaptainVehicleImageUrl('cpt-101');

      expect(profileUrl, isNotNull);
      expect(vehicleUrl, isNotNull);
      expect(profileUrl, isNot(equals(vehicleUrl)));
    });
  });
}
