import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickride_admin/services/admin_connectivity_service.dart';
import 'package:quickride_admin/core/errors/admin_error_handler.dart';
import 'package:quickride_admin/widgets/admin_offline_banner.dart';
import 'package:quickride_admin/services/admin_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 49: QuickRide Admin Error Handling & Offline Support Tests', () {
    late AdminConnectivityService connectivity;

    setUp(() {
      connectivity = AdminConnectivityService();
      connectivity.setMockOnlineState(true);
    });

    tearDown(() {
      connectivity.setMockOnlineState(true);
    });

    group('1. AdminConnectivityService & Reconnection Synchronization', () {
      test('Initial connectivity defaults to online', () {
        expect(connectivity.isOnline, isTrue);
        expect(connectivity.isOffline, isFalse);
      });

      test('Toggling mock state updates isOnline and isOffline', () {
        connectivity.setMockOnlineState(false);
        expect(connectivity.isOnline, isFalse);
        expect(connectivity.isOffline, isTrue);

        connectivity.setMockOnlineState(true);
        expect(connectivity.isOnline, isTrue);
        expect(connectivity.isOffline, isFalse);
      });

      test('onConnectivityChanged stream emits status updates in order', () async {
        final events = <bool>[];
        final sub = connectivity.onConnectivityChanged.listen((status) {
          events.add(status);
        });

        connectivity.setMockOnlineState(false);
        connectivity.setMockOnlineState(true);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        await sub.cancel();

        expect(events, containsAllInOrder([false, true]));
      });

      test('Reconnection listener fires when connection restored', () async {
        bool reconnected = false;
        connectivity.addReconnectionListener(() async {
          reconnected = true;
        });

        connectivity.setMockOnlineState(false);
        expect(reconnected, isFalse);

        connectivity.setMockOnlineState(true);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(reconnected, isTrue);
      });
    });

    group('2. AdminErrorHandler Exception Mapping', () {
      test('Translates Admin Auth exception codes to friendly strings', () {
        final notFound = FirebaseAuthException(code: 'user-not-found');
        expect(AdminErrorHandler.getFriendlyErrorMessage(notFound), contains('No Admin account'));

        final wrongPass = FirebaseAuthException(code: 'wrong-password');
        expect(AdminErrorHandler.getFriendlyErrorMessage(wrongPass), contains('Invalid admin credentials'));

        final disabled = FirebaseAuthException(code: 'user-disabled');
        expect(AdminErrorHandler.getFriendlyErrorMessage(disabled), contains('account has been disabled'));
      });

      test('Translates Firestore and network exceptions for Admin console', () {
        final permDenied = FirebaseException(plugin: 'firestore', code: 'permission-denied');
        expect(AdminErrorHandler.getFriendlyErrorMessage(permDenied), contains('Access denied'));

        const socketErr = SocketException('Connection failed');
        expect(AdminErrorHandler.getFriendlyErrorMessage(socketErr), contains('No internet connection'));

        final timeoutErr = TimeoutException('Timeout');
        expect(AdminErrorHandler.getFriendlyErrorMessage(timeoutErr), contains('timed out'));
      });
    });

    group('3. AdminOfflineBanner Widget Tests', () {
      testWidgets('Hidden when Admin Console is online', (tester) async {
        connectivity.setMockOnlineState(true);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AdminOfflineBanner(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Admin Console Offline: Showing locally cached metrics.'), findsNothing);
      });

      testWidgets('Displays offline banner and handles reconnect when offline', (tester) async {
        connectivity.setMockOnlineState(false);

        bool reconnected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdminOfflineBanner(
                onRetry: () => reconnected = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Admin Console Offline: Showing locally cached metrics.'), findsOneWidget);
        expect(find.text('RECONNECT'), findsOneWidget);

        await tester.tap(find.text('RECONNECT'));
        await tester.pump();
        expect(reconnected, isTrue);
      });
    });

    group('4. Admin Console Metrics Caching & Safe Degradation', () {
      test('Dashboard overview metrics remain accessible during offline mode', () {
        final adminState = AdminStateService();

        // Go offline
        connectivity.setMockOnlineState(false);

        final overview = adminState.dashboardOverview;
        expect(overview.totalUsers, isNonNegative);
        expect(overview.totalCaptains, isNonNegative);
        expect(overview.totalRides, isNonNegative);

        // Restore online
        connectivity.setMockOnlineState(true);
        expect(connectivity.isOnline, isTrue);
      });
    });
  });
}
