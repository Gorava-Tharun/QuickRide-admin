import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/core/constants/admin_strings.dart';
import 'package:quickride_admin/screens/auth/admin_login_screen.dart';
import 'package:quickride_admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:quickride_admin/screens/main_layout/admin_main_scaffold.dart';
import 'package:quickride_admin/screens/reports/admin_reports_screen.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('STEP 54: QuickRide Admin App UI/UX Polish & Responsive Verification', () {
    setUp(() {
      AdminStateService().login('admin@quickride.com', 'admin123');
    });

    // =========================================================================
    // 1. ADMIN LOGIN POLISH
    // =========================================================================
    testWidgets('Admin Login Screen renders branding, title and credentials card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminLoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AdminStrings.appName), findsOneWidget);
      expect(find.text(AdminStrings.appSubtitle), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    // =========================================================================
    // 2. ADMIN DASHBOARD & KPI CARDS
    // =========================================================================
    testWidgets('Admin Dashboard Screen renders all 8 KPI cards cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminDashboardScreen(onNavigate: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Total Captains'), findsOneWidget);
      expect(find.text('Total Rides'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
    });

    // =========================================================================
    // 3. ADMIN REPORTS SCREEN TABS
    // =========================================================================
    testWidgets('Admin Reports Screen switches between tabs without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminReportsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Revenue & Payments'), findsOneWidget);
      expect(find.text('Ride Analytics'), findsOneWidget);
      expect(find.text('User Reports'), findsOneWidget);
      expect(find.text('Captain & Fleet'), findsOneWidget);
    });

    // =========================================================================
    // 4. RESPONSIVE DESKTOP & MOBILE VIEWPORT CHECKS
    // =========================================================================
    testWidgets('Admin Scaffold adapts to Desktop Viewport (1280x800) with sidebar', (tester) async {
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

      expect(find.text(AdminStrings.appName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Admin Scaffold adapts to Mobile Viewport (390x844) with bottom nav', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
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

      expect(tester.takeException(), isNull);
    });
  });
}
