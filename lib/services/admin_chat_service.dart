import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/firestore_models.dart';
import 'admin_firebase_service.dart';

/// Admin chat service for auditing and viewing communication logs between User and Captain.
class AdminChatService extends ChangeNotifier {
  AdminChatService._internal();

  static final AdminChatService _instance = AdminChatService._internal();
  factory AdminChatService() => _instance;

  /// Stream chat log for a ride
  Stream<List<FirestoreChatMessageModel>> streamMessages(String rideId) {
    return AdminFirebaseService().streamChatMessages(rideId);
  }

  /// Fetch chat log for a ride
  Future<List<FirestoreChatMessageModel>> fetchMessages(String rideId) {
    return AdminFirebaseService().fetchChatMessages(rideId);
  }

  /// Send an administrative message or note in the ride thread
  Future<bool> sendAdminMessage({
    required String rideId,
    required String adminId,
    required String adminName,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;

    final messageId = 'msg_adm_${DateTime.now().millisecondsSinceEpoch}';
    final chatMsg = FirestoreChatMessageModel(
      messageId: messageId,
      rideId: rideId,
      senderId: adminId,
      senderRole: 'ADMIN',
      senderName: adminName,
      message: trimmed,
      createdAt: DateTime.now(),
      read: true,
    );

    final success = await AdminFirebaseService().sendAdminChatMessage(chatMsg);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Clears in-memory messages for testing
  void reset([String? rideId]) {
    AdminFirebaseService().clearLocalChatMessages(rideId);
    notifyListeners();
  }
}
