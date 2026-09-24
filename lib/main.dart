import 'package:flutter/material.dart';
import 'core/constants/admin_strings.dart';
import 'core/theme/admin_theme.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/main_layout/admin_main_scaffold.dart';
import 'services/admin_firebase_service.dart';
import 'services/admin_state_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with graceful fallback
  await AdminFirebaseService().initialize();

  runApp(const QuickRideAdminApp());
}

class QuickRideAdminApp extends StatelessWidget {
  const QuickRideAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AdminStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      home: AdminStateService().isLoggedIn
          ? const AdminMainScaffold()
          : const AdminLoginScreen(),
    );
  }
}
