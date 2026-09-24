import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'admin_firebase_service.dart';

class AdminStorageService {
  static final AdminStorageService _instance = AdminStorageService._internal();
  factory AdminStorageService() => _instance;
  AdminStorageService._internal();

  /// Retrieve the latest profile image URL for a user from Cloud Storage
  /// Storage path: users/{userId}/profile/
  Future<String?> getUserProfileImageUrl(String userId, {String? defaultFallback}) async {
    final firebaseService = AdminFirebaseService();
    if (!firebaseService.isFirebaseAvailable) {
      return defaultFallback ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';
    }

    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('users/$userId/profile')
          .list(const ListOptions(maxResults: 1));

      if (result.items.isNotEmpty) {
        return await result.items.first.getDownloadURL();
      }
    } catch (e) {
      debugPrint('[AdminStorageService] Error loading user profile image: $e');
    }
    return defaultFallback;
  }

  /// Retrieve the latest profile photo for a captain from Cloud Storage
  /// Storage path: captains/{captainId}/profile/
  Future<String?> getCaptainProfileImageUrl(String captainId, {String? defaultFallback}) async {
    final firebaseService = AdminFirebaseService();
    if (!firebaseService.isFirebaseAvailable) {
      return defaultFallback ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
    }

    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('captains/$captainId/profile')
          .list(const ListOptions(maxResults: 1));

      if (result.items.isNotEmpty) {
        return await result.items.first.getDownloadURL();
      }
    } catch (e) {
      debugPrint('[AdminStorageService] Error loading captain profile image: $e');
    }
    return defaultFallback;
  }

  /// Retrieve the latest vehicle photo for a captain from Cloud Storage
  /// Storage path: captains/{captainId}/vehicle/
  Future<String?> getCaptainVehicleImageUrl(String captainId, {String? defaultFallback}) async {
    final firebaseService = AdminFirebaseService();
    if (!firebaseService.isFirebaseAvailable) {
      return defaultFallback ?? 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80';
    }

    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('captains/$captainId/vehicle')
          .list(const ListOptions(maxResults: 1));

      if (result.items.isNotEmpty) {
        return await result.items.first.getDownloadURL();
      }
    } catch (e) {
      debugPrint('[AdminStorageService] Error loading captain vehicle photo: $e');
    }
    return defaultFallback;
  }
}
