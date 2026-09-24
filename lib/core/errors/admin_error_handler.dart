import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/admin_colors.dart';

/// Centralized Error & Exception Handler for QuickRide Admin App.
class AdminErrorHandler {
  AdminErrorHandler._();

  /// Translates raw technical exceptions into friendly user strings.
  static String getFriendlyErrorMessage(Object? error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (error is FirebaseAuthException) {
      switch (error.code.toLowerCase()) {
        case 'user-not-found':
          return 'No Admin account associated with this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid admin credentials.';
        case 'user-disabled':
          return 'This administrator account has been disabled.';
        case 'too-many-requests':
          return 'Too many login attempts. Please wait a moment.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'Authentication error. Please try again.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code.toLowerCase()) {
        case 'permission-denied':
          return 'Access denied. Administrative authorization required.';
        case 'unavailable':
          return 'Firestore service unavailable. Operating in local cache mode.';
        case 'not-found':
          return 'Requested record or document not found.';
        case 'deadline-exceeded':
          return 'Request timed out. Please retry.';
        default:
          return error.message ?? 'Database operation failed.';
      }
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and retry.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please check your network connection.';
    }

    final str = error.toString();
    if (str.contains('SocketException') || str.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network and retry.';
    }

    return 'Operation could not be completed. Please try again.';
  }

  /// Displays a styled error SnackBar with optional retry action.
  static void showErrorSnackBar(
    BuildContext context,
    Object? error, {
    VoidCallback? onRetry,
    String? customMessage,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = customMessage ?? getFriendlyErrorMessage(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Displays a success SnackBar.
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}
