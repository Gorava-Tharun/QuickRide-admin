import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 56: QuickRide Admin Console Production Firebase Configuration & Safety Verification', () {
    test('AdminFirebaseService testConnection reports valid production appId and collection schema', () async {
      final fb = AdminFirebaseService();
      final diag = await fb.testConnection();

      expect(diag['appId'], 'com.quickride.admin');
      expect(diag['managedCollections'], contains('users'));
      expect(diag['managedCollections'], contains('captains'));
      expect(diag['managedCollections'], contains('rides'));
      expect(diag['managedCollections'], contains('payments'));
      expect(diag['managedCollections'], contains('emergencies'));
    });

    test('AdminStateService validates authorized admin credentials and rejects unauthorized users', () {
      final state = AdminStateService();

      // Unauthorized user with invalid credentials rejected
      final invalidLogin = state.login('invalid', '123');
      expect(invalidLogin, isFalse);

      // Authorized admin accepted
      final validLogin = state.login('admin@quickride.com', 'admin123');
      expect(validLogin, isTrue);
      expect(state.isLoggedIn, isTrue);

      // Logout clears session
      state.logout();
      expect(state.isLoggedIn, isFalse);
    });

    test('AdminFirebaseService streams handle fallback collections gracefully', () {
      final fb = AdminFirebaseService();
      expect(fb.streamUsers(), isA<Stream>());
      expect(fb.streamCaptains(), isA<Stream>());
      expect(fb.streamRides(), isA<Stream>());
      expect(fb.streamComplaints(), isA<Stream>());
      expect(fb.streamPayments(), isA<Stream>());
    });
  });
}
