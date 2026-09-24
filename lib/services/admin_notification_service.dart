import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';
import 'admin_firebase_service.dart';

/// Singleton Service managing Admin Push & In-App Notifications
class AdminNotificationService extends ChangeNotifier {
  static final AdminNotificationService _instance = AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal() {
    _seedDefaultNotifications();
    _initFirestoreStream();
  }

  final List<FirestoreNotificationModel> _notifications = [];
  bool _hasSeeded = false;
  StreamSubscription<QuerySnapshot>? _firestoreSub;

  int get unreadCount => _notifications.where((n) => !n.read).length;
  List<FirestoreNotificationModel> get notifications => List.unmodifiable(_notifications);

  void _seedDefaultNotifications() {
    if (_hasSeeded) return;
    _hasSeeded = true;

    final now = DateTime.now();
    _notifications.addAll([
      FirestoreNotificationModel(
        notificationId: 'notif_adm_01',
        recipientId: 'admin_all',
        recipientRole: 'admin',
        title: 'New Complaint Filed',
        message: 'Ticket #CPT-1001: Fare discrepancy reported by Passenger Rajesh.',
        type: 'NEW_COMPLAINT',
        read: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
        complaintId: 'CPT-1001',
      ),
      FirestoreNotificationModel(
        notificationId: 'notif_adm_02',
        recipientId: 'admin_all',
        recipientRole: 'admin',
        title: 'Ride Cancelled',
        message: 'Ride #RIDE-8821 was cancelled by passenger (Reason: Changed plans).',
        type: 'RIDE_CANCELLED',
        read: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
        rideId: 'RIDE-8821',
      ),
      FirestoreNotificationModel(
        notificationId: 'notif_adm_03',
        recipientId: 'admin_all',
        recipientRole: 'admin',
        title: 'Refund Processed',
        message: 'Refund of ₹185.00 completed for cancelled Ride #RIDE-7712.',
        type: 'PAYMENT_REFUNDED',
        read: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        rideId: 'RIDE-7712',
      ),
      FirestoreNotificationModel(
        notificationId: 'notif_adm_04',
        recipientId: 'admin_all',
        recipientRole: 'admin',
        title: 'Safety SOS Alert Resolved',
        message: 'SOS incident #EMG-902 on Ride #RIDE-5501 resolved successfully.',
        type: 'EMERGENCY_STATUS',
        read: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        emergencyId: 'EMG-902',
        rideId: 'RIDE-5501',
      ),
    ]);
  }

  void _initFirestoreStream() {
    final fb = AdminFirebaseService();
    if (!fb.isFirebaseAvailable) return;

    try {
      _firestoreSub = FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .snapshots()
          .listen(
        (snapshot) {
          for (final doc in snapshot.docs) {
            final notif = FirestoreNotificationModel.fromMap(doc.data(), id: doc.id);
            addNotification(notif);
          }
        },
        onError: (err) {
          debugPrint('[AdminNotificationService] Firestore stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('[AdminNotificationService] Init stream error: $e');
    }
  }

  void addNotification(FirestoreNotificationModel notification) {
    _notifications.removeWhere((n) => n.notificationId == notification.notificationId);
    _notifications.insert(0, notification);
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1 && !_notifications[index].read) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();

      final fb = AdminFirebaseService();
      if (fb.isFirebaseAvailable) {
        try {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationId)
              .update({'read': true});
        } catch (_) {}
      }
    }
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].read) {
        _notifications[i] = _notifications[i].copyWith(read: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }

    final fb = AdminFirebaseService();
    if (fb.isFirebaseAvailable) {
      try {
        final unreadDocs = await FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientRole', isEqualTo: 'admin')
            .where('read', isEqualTo: false)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in unreadDocs.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void resetToDefault() {
    _notifications.clear();
    _hasSeeded = false;
    _seedDefaultNotifications();
    notifyListeners();
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    super.dispose();
  }
}
