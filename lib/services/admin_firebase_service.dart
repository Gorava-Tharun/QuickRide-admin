import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';

class AdminFirebaseService {
  static final AdminFirebaseService _instance =
      AdminFirebaseService._internal();
  factory AdminFirebaseService() => _instance;
  AdminFirebaseService._internal();

  bool _isFirebaseAvailable = false;
  String _statusMessage = 'Uninitialized';

  bool get isFirebaseAvailable => _isFirebaseAvailable;
  String get statusMessage => _statusMessage;

  /// Safe initialization catching missing config without crashing
  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
        _statusMessage = 'Firebase connected (Default App)';
        debugPrint('[$statusMessage]');
        return true;
      }

      await Firebase.initializeApp();
      _isFirebaseAvailable = true;
      _statusMessage = 'Firebase initialized successfully';
      debugPrint('[$statusMessage]');
      return true;
    } catch (e) {
      _isFirebaseAvailable = false;
      _statusMessage = 'Firebase Offline / Local Fallback Mode: $e';
      debugPrint('[Admin Firebase] Note: $statusMessage');
      return false;
    }
  }

  /// Read users collection from Firestore
  Future<List<FirestoreUserModel>> fetchUsers({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').limit(limit).get();
      return snapshot.docs
          .map((doc) => FirestoreUserModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching users: $e');
      return [];
    }
  }

  /// Real-time stream of users from Firestore
  Stream<List<FirestoreUserModel>> streamUsers({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreUserModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Read captains collection from Firestore
  Future<List<FirestoreCaptainModel>> fetchCaptains({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('captains').limit(limit).get();
      return snapshot.docs
          .map((doc) => FirestoreCaptainModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching captains: $e');
      return [];
    }
  }

  /// Real-time stream of captains from Firestore
  Stream<List<FirestoreCaptainModel>> streamCaptains({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('captains')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreCaptainModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Read rides collection from Firestore
  Future<List<SharedRideModel>> fetchRides({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('rides').limit(limit).get();
      return snapshot.docs
          .map((doc) => SharedRideModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching rides: $e');
      return [];
    }
  }

  /// Real-time stream of rides from Firestore
  Stream<List<SharedRideModel>> streamRides({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('rides')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedRideModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Read ratings collection from Firestore
  Future<List<FirestoreRatingModel>> fetchRatings({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('ratings').limit(limit).get();
      return snapshot.docs
          .map((doc) => FirestoreRatingModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching ratings: $e');
      return [];
    }
  }

  /// Real-time stream of ratings from Firestore
  Stream<List<FirestoreRatingModel>> streamRatings({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('ratings')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreRatingModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Read offers collection from Firestore
  Future<List<FirestoreOfferModel>> fetchOffers({int limit = 50}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('offers').limit(limit).get();
      return snapshot.docs
          .map((doc) => FirestoreOfferModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching offers: $e');
      return [];
    }
  }

  /// Real-time stream of offers from Firestore
  Stream<List<FirestoreOfferModel>> streamOffers({int limit = 50}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('offers')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreOfferModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Create a new promotional offer in Firestore
  Future<bool> createOffer(FirestoreOfferModel offer) async {
    if (!_isFirebaseAvailable) return true;
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offer.offerId)
          .set(offer.toMap());
      debugPrint('[Admin Firebase] Offer created: ${offer.offerId}');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error creating offer: $e');
      return false;
    }
  }

  /// Update an existing offer in Firestore
  Future<bool> updateOffer(FirestoreOfferModel offer) async {
    if (!_isFirebaseAvailable) return true;
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offer.offerId)
          .update(offer.toMap());
      debugPrint('[Admin Firebase] Offer updated: ${offer.offerId}');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error updating offer: $e');
      return false;
    }
  }

  /// Toggle active state of an offer
  Future<bool> toggleOfferActive(String offerId, bool active) async {
    if (!_isFirebaseAvailable) return true;
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .update({
        'active': active,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('[Admin Firebase] Offer $offerId active set to $active');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error toggling offer active: $e');
      return false;
    }
  }

  /// Delete an offer from Firestore
  Future<bool> deleteOffer(String offerId) async {
    if (!_isFirebaseAvailable) return true;
    try {
      await FirebaseFirestore.instance.collection('offers').doc(offerId).delete();
      debugPrint('[Admin Firebase] Offer deleted: $offerId');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error deleting offer: $e');
      return false;
    }
  }

  /// Real-time stream of payments from Firestore
  Stream<List<FirestorePaymentModel>> streamPayments({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('payments')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestorePaymentModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Fetch payments once from Firestore
  Future<List<FirestorePaymentModel>> fetchPayments({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => FirestorePaymentModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching payments: $e');
      return [];
    }
  }

  /// Update payment status (Admin capability)
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    if (!_isFirebaseAvailable) return true;
    try {
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(paymentId)
          .update({
        'paymentStatus': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('[Admin Firebase] Payment $paymentId status updated to $status');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error updating payment: $e');
      return false;
    }
  }

  /// Process refund with amounts and reasons (Admin capability)
  Future<bool> processRefund(
    String paymentId, {
    required double refundAmount,
    double cancellationFee = 0.0,
    String reason = 'Admin initiated refund',
    String? rideId,
  }) async {
    if (!_isFirebaseAvailable) return true;
    try {
      final now = DateTime.now();
      final refundId = 'REF_${now.millisecondsSinceEpoch}';
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(paymentId)
          .update({
        'paymentStatus': 'REFUNDED',
        'refundAmount': refundAmount,
        'cancellationFee': cancellationFee,
        'refundReason': reason,
        'refundId': refundId,
        'refundedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      if (rideId != null && rideId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
          'refundAmount': refundAmount,
          'cancellationFee': cancellationFee,
          'refundStatus': 'COMPLETED',
          'refundId': refundId,
          'refundedAt': now.toIso8601String(),
          'paymentStatus': 'REFUNDED',
          'updatedAt': now.toIso8601String(),
        });
      }
      debugPrint(
          '[Admin Firebase] Refund processed for payment $paymentId: ₹$refundAmount');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error processing refund: $e');
      return false;
    }
  }

  // ===========================================================================
  // STEP 39: ADMIN CUSTOMER SUPPORT & COMPLAINTS MANAGEMENT
  // ===========================================================================

  /// Real-time stream of all complaints from Firestore
  Stream<List<FirestoreComplaintModel>> streamComplaints({int limit = 100}) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('complaints')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => FirestoreComplaintModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Fetch all complaints once from Firestore
  Future<List<FirestoreComplaintModel>> fetchComplaints({int limit = 100}) async {
    if (!_isFirebaseAvailable) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .limit(limit)
          .get();
      final list = snapshot.docs
          .map((doc) => FirestoreComplaintModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching complaints: $e');
      return [];
    }
  }

  /// Update complaint fields (Status, Priority, Admin Notes, Resolution Summary)
  Future<bool> updateComplaint(String complaintId, Map<String, dynamic> updates) async {
    if (!_isFirebaseAvailable) return true;
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update(updates);
      debugPrint('[Admin Firebase] Complaint $complaintId updated successfully');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error updating complaint $complaintId: $e');
      return false;
    }
  }

  /// Real-time stream of conversation replies for a complaint
  Stream<List<FirestoreComplaintReplyModel>> streamComplaintReplies(String complaintId) {
    if (!_isFirebaseAvailable) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .collection('replies')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => FirestoreComplaintReplyModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Add a message reply from Admin to a complaint thread
  Future<bool> addComplaintReply(FirestoreComplaintReplyModel reply) async {
    if (!_isFirebaseAvailable) return true;
    try {
      final batch = FirebaseFirestore.instance.batch();
      final replyRef = FirebaseFirestore.instance
          .collection('complaints')
          .doc(reply.complaintId)
          .collection('replies')
          .doc(reply.replyId);
      final complaintRef = FirebaseFirestore.instance
          .collection('complaints')
          .doc(reply.complaintId);

      batch.set(replyRef, reply.toMap());
      batch.update(complaintRef, {'updatedAt': DateTime.now().toIso8601String()});
      await batch.commit();

      debugPrint('[Admin Firebase] Admin reply added to complaint: ${reply.complaintId}');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error adding admin reply: $e');
      return false;
    }
  }

  // ==========================================================================
  // STEP 40: SAFETY & EMERGENCY (SOS) MONITORING
  // ==========================================================================

  final List<FirestoreEmergencyIncidentModel> _localEmergencies = [
    FirestoreEmergencyIncidentModel(
      emergencyId: 'EMG_RIDE_101_LIVE',
      rideId: 'RIDE_101',
      userId: 'user_quickride_01',
      captainId: 'captain_seed_01',
      latitude: 12.9756,
      longitude: 77.6066,
      status: EmergencyStatus.active,
      triggeredBy: 'user',
      userName: 'Alex Johnson',
      userPhone: '+91 98765 43210',
      captainName: 'Vikram Singh',
      captainPhone: '+91 98450 77123',
      vehicleNumber: 'KA 03 AB 1234',
      vehicleType: 'Bike',
      pickup: 'MG Road Metro Station',
      destination: 'Indiranagar 100ft Road',
      adminNotes: 'Rider reported sudden deviation from requested route',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    FirestoreEmergencyIncidentModel(
      emergencyId: 'EMG_RIDE_102_ACK',
      rideId: 'RIDE_102',
      userId: 'user_priya_02',
      captainId: 'captain_seed_02',
      latitude: 12.9345,
      longitude: 77.6265,
      status: EmergencyStatus.acknowledged,
      triggeredBy: 'captain',
      userName: 'Priya Sharma',
      userPhone: '+91 99801 22334',
      captainName: 'Rajesh Kumar',
      captainPhone: '+91 97412 55667',
      vehicleNumber: 'KA 05 CD 5678',
      vehicleType: 'Auto',
      pickup: 'Koramangala 4th Block',
      destination: 'Electronic City Phase 1',
      adminNotes: 'Field safety officer contacted captain. Vehicle breakdown on highway.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    FirestoreEmergencyIncidentModel(
      emergencyId: 'EMG_RIDE_103_RES',
      rideId: 'RIDE_103',
      userId: 'user_rahul_03',
      captainId: 'captain_seed_03',
      latitude: 12.9279,
      longitude: 77.6271,
      status: EmergencyStatus.resolved,
      triggeredBy: 'user',
      userName: 'Rahul Verma',
      userPhone: '+91 98451 99887',
      captainName: 'Anil Desai',
      captainPhone: '+91 99001 11223',
      vehicleNumber: 'KA 01 EF 9012',
      vehicleType: 'Cab',
      pickup: 'HSR Layout Sector 1',
      destination: 'Bellandur EcoSpace',
      adminNotes: 'Spoke with passenger on call. Confirmed false alarm.',
      resolutionSummary: 'Verified false alarm by passenger call.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  /// Stream all emergency incidents sorted newest first
  Stream<List<FirestoreEmergencyIncidentModel>> streamEmergencies() {
    if (!_isFirebaseAvailable) {
      final list = List<FirestoreEmergencyIncidentModel>.from(_localEmergencies);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Stream.value(list);
    }

    return FirebaseFirestore.instance
        .collection('emergencies')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => FirestoreEmergencyIncidentModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Fetch all emergency incidents once
  Future<List<FirestoreEmergencyIncidentModel>> fetchEmergencies() async {
    if (!_isFirebaseAvailable) {
      final list = List<FirestoreEmergencyIncidentModel>.from(_localEmergencies);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('emergencies').get();
      final list = snapshot.docs
          .map((doc) => FirestoreEmergencyIncidentModel.fromMap(doc.data(), id: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching emergencies: $e');
      final list = List<FirestoreEmergencyIncidentModel>.from(_localEmergencies);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  /// Update status and notes of an emergency incident
  Future<bool> updateEmergencyStatus(
    String emergencyId,
    EmergencyStatus status, {
    String? adminNotes,
    String? resolutionSummary,
  }) async {
    final now = DateTime.now();
    final idx = _localEmergencies.indexWhere((e) => e.emergencyId == emergencyId);
    if (idx != -1) {
      _localEmergencies[idx] = _localEmergencies[idx].copyWith(
        status: status,
        adminNotes: adminNotes ?? _localEmergencies[idx].adminNotes,
        resolutionSummary: resolutionSummary ?? _localEmergencies[idx].resolutionSummary,
        updatedAt: now,
        resolvedAt: (status == EmergencyStatus.resolved || status == EmergencyStatus.closed) ? now : null,
      );
    }

    if (!_isFirebaseAvailable) {
      debugPrint('[Admin Firebase] Offline mode: emergency status updated locally: $emergencyId -> ${status.name}');
      return true;
    }

    try {
      final updateData = <String, dynamic>{
        'status': status.name.toUpperCase(),
        'updatedAt': now.toIso8601String(),
      };
      if (adminNotes != null) updateData['adminNotes'] = adminNotes;
      if (resolutionSummary != null) updateData['resolutionSummary'] = resolutionSummary;
      if (status == EmergencyStatus.resolved || status == EmergencyStatus.closed) {
        updateData['resolvedAt'] = now.toIso8601String();
      }

      await FirebaseFirestore.instance
          .collection('emergencies')
          .doc(emergencyId)
          .update(updateData);
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error updating emergency status: $e');
      return false;
    }
  }

  /// Update captain document and vehicle verification in Firestore
  Future<bool> updateCaptainVerification(
    String captainId, {
    required String verificationStatus,
    required String vehicleVerificationStatus,
    String? rejectionReason,
    DateTime? verifiedAt,
  }) async {
    if (!_isFirebaseAvailable) {
      debugPrint('[Admin Firebase] Local fallback: Updated verification for $captainId to $verificationStatus');
      return true;
    }

    try {
      final updateData = <String, dynamic>{
        'verificationStatus': verificationStatus,
        'vehicleVerificationStatus': vehicleVerificationStatus,
        'verified': verificationStatus == 'APPROVED',
        'isVerified': verificationStatus == 'APPROVED',
      };
      if (verifiedAt != null) {
        updateData['verifiedAt'] = verifiedAt.toIso8601String();
      }
      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      } else if (verificationStatus == 'APPROVED') {
        updateData['rejectionReason'] = null;
      }

      await FirebaseFirestore.instance
          .collection('captains')
          .doc(captainId)
          .update(updateData);
      debugPrint('[Admin Firebase] Successfully updated verification for $captainId to $verificationStatus');
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error updating captain verification: $e');
      return false;
    }
  }

  // ==========================================================================
  // STEP 45: REAL-TIME CHAT LOGS
  // ==========================================================================

  final Map<String, List<FirestoreChatMessageModel>> _localChatMessages = {};
  final Map<String, StreamController<List<FirestoreChatMessageModel>>> _chatControllers = {};

  StreamController<List<FirestoreChatMessageModel>> _getChatController(String rideId) {
    return _chatControllers.putIfAbsent(
      rideId,
      () => StreamController<List<FirestoreChatMessageModel>>.broadcast(),
    );
  }

  /// Stream real-time chat messages for a ride (Admin support inspection)
  Stream<List<FirestoreChatMessageModel>> streamChatMessages(String rideId) {
    if (!_isFirebaseAvailable) {
      final controller = _getChatController(rideId);
      final messages = _localChatMessages[rideId] ?? [];
      Future.microtask(() {
        if (!controller.isClosed) {
          controller.add(List.unmodifiable(messages));
        }
      });
      return controller.stream;
    }

    try {
      return FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FirestoreChatMessageModel.fromMap(doc.data(), id: doc.id))
              .toList());
    } catch (e) {
      debugPrint('[Admin Firebase] Error streaming chat messages for ride $rideId: $e');
      final controller = _getChatController(rideId);
      final messages = _localChatMessages[rideId] ?? [];
      Future.microtask(() {
        if (!controller.isClosed) {
          controller.add(List.unmodifiable(messages));
        }
      });
      return controller.stream;
    }
  }

  /// Fetch one-time chat message list
  Future<List<FirestoreChatMessageModel>> fetchChatMessages(String rideId) async {
    if (!_isFirebaseAvailable) {
      return List.unmodifiable(_localChatMessages[rideId] ?? []);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => FirestoreChatMessageModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('[Admin Firebase] Error fetching chat messages: $e');
      return List.unmodifiable(_localChatMessages[rideId] ?? []);
    }
  }

  /// Send message as Admin or System
  Future<bool> sendAdminChatMessage(FirestoreChatMessageModel message) async {
    final list = _localChatMessages.putIfAbsent(message.rideId, () => []);
    list.add(message);
    _getChatController(message.rideId).add(List.unmodifiable(list));

    if (!_isFirebaseAvailable) return true;

    try {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(message.rideId)
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());
      return true;
    } catch (e) {
      debugPrint('[Admin Firebase] Error sending admin chat message: $e');
      return false;
    }
  }

  /// Clear in-memory chat messages (for hermetic unit testing)
  void clearLocalChatMessages([String? rideId]) {
    if (rideId != null) {
      _localChatMessages.remove(rideId);
      _getChatController(rideId).add([]);
    } else {
      _localChatMessages.clear();
      for (final controller in _chatControllers.values) {
        if (!controller.isClosed) {
          controller.add([]);
        }
      }
    }
  }

  /// Diagnostic connection test
  Future<Map<String, dynamic>> testConnection() async {
    return {
      'isFirebaseAvailable': _isFirebaseAvailable,
      'status': _statusMessage,
      'appId': 'com.quickride.admin',
      'managedCollections': [
        'users',
        'captains',
        'rides',
        'ratings',
        'complaints',
        'offers',
        'notifications',
        'payments',
        'emergencies',
      ],
    };
  }
}

