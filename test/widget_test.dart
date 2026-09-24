import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/core/constants/admin_strings.dart';
import 'package:quickride_admin/main.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  testWidgets('QuickRide Admin App smoke test', (WidgetTester tester) async {
    AdminStateService().logout();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuickRideAdminApp());
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed.
    expect(find.text(AdminStrings.appName), findsOneWidget);
    expect(find.text('Login to Dashboard'), findsOneWidget);
  });
}
