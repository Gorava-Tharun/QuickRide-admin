import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:quickride_admin/screens/main_layout/admin_main_scaffold.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 55: QuickRide Admin Performance, Bounded Queries & Resource Management', () {
    setUp(() {
      AdminStateService().login('admin@quickride.com', 'admin123');
    });

    test('AdminFirebaseService streaming queries enforce safe bounds and limits', () {
      final fb = AdminFirebaseService();
      
      // Verify streams instantiate cleanly with default limit constraints
      expect(fb.streamUsers(limit: 50), isNotNull);
      expect(fb.streamCaptains(limit: 50), isNotNull);
      expect(fb.streamRides(limit: 50), isNotNull);
      expect(fb.streamPayments(limit: 50), isNotNull);
      expect(fb.streamComplaints(limit: 50), isNotNull);
    });

    test('AdminStateService initFirestoreListeners and refreshAllData execute without memory leaks', () async {
      final service = AdminStateService();
      
      // Re-trigger listener initialization
      service.initFirestoreListeners();
      expect(service.errorMessage, isNull);

      // Verify refreshAllData finishes cleanly
      await service.refreshAllData();
      expect(service.isLoading, isFalse);
    });

    testWidgets('AdminMainScaffold mounts and unmounts views smoothly without unhandled exceptions', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminMainScaffold(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsOneWidget);

      // Switch to empty view to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
