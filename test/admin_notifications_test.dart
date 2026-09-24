import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/models/firestore_models.dart';
import 'package:quickride_admin/services/admin_notification_service.dart';
import 'package:quickride_admin/screens/main_layout/admin_main_scaffold.dart';

void main() {
  group('Step 46: Admin Notifications Service Tests', () {
    test('AdminNotificationService initialization, seeding, and unread count', () {
      final service = AdminNotificationService();
      service.resetToDefault();

      expect(service.notifications.length, greaterThanOrEqualTo(4));
      expect(service.unreadCount, greaterThan(0));
    });

    test('AdminNotificationService markAsRead and markAllAsRead', () async {
      final service = AdminNotificationService();
      service.resetToDefault();

      final firstNotif = service.notifications.firstWhere((n) => !n.read);
      await service.markAsRead(firstNotif.notificationId);

      final updated = service.notifications.firstWhere((n) => n.notificationId == firstNotif.notificationId);
      expect(updated.read, isTrue);

      await service.markAllAsRead();
      expect(service.unreadCount, 0);
    });

    test('AdminNotificationService addNotification and clearAll', () {
      final service = AdminNotificationService();
      service.resetToDefault();

      final newNotif = FirestoreNotificationModel(
        notificationId: 'notif_adm_test_99',
        recipientId: 'admin_all',
        recipientRole: 'admin',
        title: 'New Escalated Ticket',
        message: 'Ticket #CPT-9999 requires admin review.',
        type: 'URGENT_COMPLAINT',
        read: false,
        createdAt: DateTime.now(),
      );

      service.addNotification(newNotif);
      expect(service.notifications.first.notificationId, 'notif_adm_test_99');

      service.clearAll();
      expect(service.notifications.isEmpty, isTrue);
      expect(service.unreadCount, 0);
    });
  });

  group('Step 46: AdminMainScaffold Notification Bell & Dialog UI Tests', () {
    testWidgets('AdminMainScaffold renders notification bell and opens notification dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AdminNotificationService().resetToDefault();

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminMainScaffold(),
        ),
      );
      await tester.pumpAndSettle();

      final bellFinder = find.byTooltip('Notifications');
      expect(bellFinder, findsWidgets);

      // Tap notification bell to open dialog
      await tester.tap(bellFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Notifications & Alerts'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications & Alerts'), findsNothing);
    });
  });
}
