import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/core/constants/admin_strings.dart';
import 'package:quickride_admin/screens/auth/admin_login_screen.dart';
import 'package:quickride_admin/screens/main_layout/admin_main_scaffold.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  setUp(() {
    AdminStateService().logout();
  });

  test('AdminStateService handles credentials, mock login and logout', () {
    final service = AdminStateService();
    expect(service.isLoggedIn, isFalse);

    // Invalid credentials
    final failResult = service.login('wrong@quickride.com', '123');
    expect(failResult, isFalse);
    expect(service.isLoggedIn, isFalse);

    // Valid demo credentials
    final successResult = service.login('admin@quickride.com', 'admin123');
    expect(successResult, isTrue);
    expect(service.isLoggedIn, isTrue);
    expect(service.adminEmail, 'admin@quickride.com');

    // Logout
    service.logout();
    expect(service.isLoggedIn, isFalse);
  });

  testWidgets('AdminLoginScreen renders branding and performs login navigation', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AdminStrings.appName), findsOneWidget);
    expect(find.text(AdminStrings.demoBadge), findsOneWidget);
    expect(find.text('Login to Dashboard'), findsOneWidget);

    // Tap Login button with pre-filled demo credentials
    await tester.tap(find.text('Login to Dashboard'));
    await tester.pumpAndSettle();

    // Verify navigation to AdminMainScaffold
    expect(find.byType(AdminMainScaffold), findsOneWidget);
  });
}
