import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickride_admin/services/admin_state_service.dart';
import 'package:quickride_admin/services/admin_firebase_service.dart';
import 'package:quickride_admin/models/firestore_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 48: QuickRide Security & Firebase Rules Audit Tests', () {
    late String firestoreRulesContent;
    late String storageRulesContent;

    setUpAll(() {
      final firestoreFile = File('../firestore.rules');
      final fallbackFirestoreFile = File('firestore.rules');
      final targetFirestore = firestoreFile.existsSync() ? firestoreFile : fallbackFirestoreFile;
      firestoreRulesContent = targetFirestore.existsSync() ? targetFirestore.readAsStringSync() : '';

      final storageFile = File('../storage.rules');
      final fallbackStorageFile = File('storage.rules');
      final targetStorage = storageFile.existsSync() ? storageFile : fallbackStorageFile;
      storageRulesContent = targetStorage.existsSync() ? targetStorage.readAsStringSync() : '';
    });

    group('1. Firestore Rules Security Audit', () {
      test('firestore.rules file exists and is populated', () {
        expect(firestoreRulesContent.isNotEmpty, isTrue);
        expect(firestoreRulesContent, contains("rules_version = '2';"));
        expect(firestoreRulesContent, contains('service cloud.firestore'));
      });

      test('Strictly forbids open/insecure rules (allow read, write: if true;)', () {
        expect(firestoreRulesContent.contains('allow read, write: if true;'), isFalse);
        expect(firestoreRulesContent.contains('allow write: if true;'), isFalse);
        expect(firestoreRulesContent.contains('allow read: if true;'), isFalse);
      });

      test('Contains helper functions for authentication, ownership, and admin verification', () {
        expect(firestoreRulesContent, contains('function isAuthenticated()'));
        expect(firestoreRulesContent, contains('function isOwner(userId)'));
        expect(firestoreRulesContent, contains('function isAdmin()'));
        expect(firestoreRulesContent, contains("request.auth.token.email.matches('.*@quickride\\\\.com\$')"));
      });

      test('Secures /users/{userId} with protected fields and ownership rules', () {
        expect(firestoreRulesContent, contains('match /users/{userId}'));
        expect(firestoreRulesContent, contains('isOwner(userId) || isAdmin()'));
        expect(firestoreRulesContent, contains("'userId', 'role', 'status', 'createdAt', 'rating', 'totalRatings'"));
        expect(firestoreRulesContent, contains('match /emergency_contacts/{contactId}'));
      });

      test('Secures /captains/{captainId} with verification protection', () {
        expect(firestoreRulesContent, contains('match /captains/{captainId}'));
        expect(firestoreRulesContent, contains('isOwner(captainId) || isAdmin()'));
        expect(firestoreRulesContent, contains("'verified', 'isVerified', 'verificationStatus'"));
        expect(firestoreRulesContent, contains("'vehicleVerificationStatus'"));
      });

      test('Secures /rides/{rideId} against unauthorized creation, fare tampering, and cancellation exploits', () {
        expect(firestoreRulesContent, contains('match /rides/{rideId}'));
        expect(firestoreRulesContent, contains("request.resource.data.status == 'REQUESTED'"));
        expect(firestoreRulesContent, contains("request.resource.data.fare >= 0"));
        expect(firestoreRulesContent, contains("request.resource.data.vehicleType in ['Bike', 'Auto', 'Car', 'Cab']"));
        expect(firestoreRulesContent, contains("request.resource.data.fare == resource.data.fare"));
      });

      test('Secures /rides/{rideId}/messages/{messageId} chat subcollection', () {
        expect(firestoreRulesContent, contains('match /messages/{messageId}'));
        expect(firestoreRulesContent, contains('isRideParticipant()'));
        expect(firestoreRulesContent, contains('isRideInActiveChatState()'));
        expect(firestoreRulesContent, contains('isValidChatMessage()'));
        expect(firestoreRulesContent, contains('request.resource.data.message.size() <= 500'));
      });

      test('Secures /ratings/{ratingId} with star and length validation', () {
        expect(firestoreRulesContent, contains('match /ratings/{ratingId}'));
        expect(firestoreRulesContent, contains('request.resource.data.stars >= 1'));
        expect(firestoreRulesContent, contains('request.resource.data.stars <= 5'));
        expect(firestoreRulesContent, contains('request.resource.data.review.size() <= 1000'));
        expect(firestoreRulesContent, contains('isRideCompleted('));
      });

      test('Secures /complaints/{complaintId} and /replies subcollection', () {
        expect(firestoreRulesContent, contains('match /complaints/{complaintId}'));
        expect(firestoreRulesContent, contains("request.resource.data.status == 'OPEN'"));
        expect(firestoreRulesContent, contains('match /replies/{replyId}'));
        expect(firestoreRulesContent, contains('request.resource.data.senderRole in ['));
      });

      test('Secures /payments/{paymentId} preventing unauthorized payment status/amount tampering', () {
        expect(firestoreRulesContent, contains('match /payments/{paymentId}'));
        expect(firestoreRulesContent, contains("request.resource.data.paymentStatus in ['PENDING', 'PROCESSING']"));
        expect(firestoreRulesContent, contains("request.resource.data.finalAmount == resource.data.finalAmount"));
        expect(firestoreRulesContent, contains("hasOnly(['paymentMethod', 'updatedAt'])"));
      });

      test('Secures /emergencies/{emergencyId} and /offers/{offerId}', () {
        expect(firestoreRulesContent, contains('match /emergencies/{emergencyId}'));
        expect(firestoreRulesContent, contains("request.resource.data.status == 'ACTIVE'"));
        expect(firestoreRulesContent, contains('match /offers/{offerId}'));
        expect(firestoreRulesContent, contains('allow write: if isAdmin();'));
      });

      test('Secures /notifications/{notificationId} and /admins/{adminId}', () {
        expect(firestoreRulesContent, contains('match /notifications/{notificationId}'));
        expect(firestoreRulesContent, contains('match /admins/{adminId}'));
        expect(firestoreRulesContent, contains('allow read, write: if isAdmin();'));
      });

      test('Enforces fallback deny rule at root level for unlisted collections', () {
        expect(firestoreRulesContent, contains('match /{document=**}'));
        expect(firestoreRulesContent, contains('allow read, write: if false;'));
      });
    });

    group('2. Firebase Storage Rules Security Audit', () {
      test('storage.rules file exists and has valid configuration', () {
        expect(storageRulesContent.isNotEmpty, isTrue);
        expect(storageRulesContent, contains("rules_version = '2';"));
        expect(storageRulesContent, contains('service firebase.storage'));
      });

      test('Strictly isolates user and captain storage directories', () {
        expect(storageRulesContent, contains('match /users/{userId}/profile/{allPaths=**}'));
        expect(storageRulesContent, contains('match /captains/{captainId}/profile/{allPaths=**}'));
        expect(storageRulesContent, contains('match /captains/{captainId}/vehicle/{allPaths=**}'));
        expect(storageRulesContent, contains('match /captains/{captainId}/documents/{allPaths=**}'));
        expect(storageRulesContent, contains('match /complaints/{userId}/{allPaths=**}'));
        expect(storageRulesContent, contains('match /emergencies/{emergencyId}/{allPaths=**}'));
      });

      test('Enforces file size <= 5MB and valid MIME type check', () {
        expect(storageRulesContent, contains('5 * 1024 * 1024'));
        expect(storageRulesContent, contains("request.resource.contentType.matches('image/.*')"));
        expect(storageRulesContent, contains("request.resource.contentType == 'application/pdf'"));
      });

      test('Enforces default deny on all other storage buckets and paths', () {
        expect(storageRulesContent, contains('match /{allPaths=**}'));
        expect(storageRulesContent, contains('allow read, write: if false;'));
      });
    });

    group('3. Application-Level Authentication & Authorization Checks', () {
      late AdminStateService adminState;

      setUp(() {
        adminState = AdminStateService();
        adminState.logout();
      });

      test('Unauthenticated user cannot access protected admin features', () {
        expect(adminState.isLoggedIn, isFalse);

        // Attempting to login with empty or invalid credentials
        final emptyAttempt = adminState.login('', '123');
        expect(emptyAttempt, isFalse);
        expect(adminState.isLoggedIn, isFalse);

        // Attempting to login with short password
        final shortPassAttempt = adminState.login('admin@quickride.com', '123');
        expect(shortPassAttempt, isFalse);
        expect(adminState.isLoggedIn, isFalse);
      });

      test('Legitimate admin authentication succeeds and persists state', () {
        final success = adminState.login('admin@quickride.com', 'admin123');
        expect(success, isTrue);
        expect(adminState.isLoggedIn, isTrue);
        expect(adminState.adminEmail, 'admin@quickride.com');

        // Logout revokes access immediately
        adminState.logout();
        expect(adminState.isLoggedIn, isFalse);
      });

      test('Firestore Captain model enforces verification status integrity', () {
        final captain = FirestoreCaptainModel(
          captainId: 'CAP-SEC-1',
          name: 'Secure Captain',
          phone: '+91 9876543210',
          email: 'captain@quickride.com',
          vehicleNumber: 'KA-01-AB-1234',
          vehicleType: 'Bike',
          drivingLicenseNumber: 'DL12345678',
          verificationStatus: 'PENDING',
          online: false,
          createdAt: DateTime.now(),
        );

        expect(captain.isApproved, isFalse);
        expect(captain.verificationStatus, 'PENDING');

        // Admin approval creates new model with verified state
        final approvedCaptain = captain.copyWith(
          verificationStatus: 'APPROVED',
          verifiedAt: DateTime.now(),
        );
        expect(approvedCaptain.isApproved, isTrue);
        expect(approvedCaptain.verificationStatus, 'APPROVED');
      });

      test('AdminFirebaseService diagnostics reports all secured collections', () async {
        final service = AdminFirebaseService();
        final diag = await service.testConnection();
        expect(diag['appId'], 'com.quickride.admin');
        final collections = diag['managedCollections'] as List<String>;
        expect(collections.contains('users'), isTrue);
        expect(collections.contains('captains'), isTrue);
        expect(collections.contains('rides'), isTrue);
        expect(collections.contains('complaints'), isTrue);
        expect(collections.contains('ratings'), isTrue);
        expect(collections.contains('offers'), isTrue);
        expect(collections.contains('notifications'), isTrue);
      });
    });
  });
}
