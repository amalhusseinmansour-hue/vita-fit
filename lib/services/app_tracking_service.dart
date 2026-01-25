import 'package:flutter/foundation.dart';

/// Tracking Status enum (replaces ATT plugin enum)
enum TrackingStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
  notSupported,
}

/// App Tracking Transparency Service - Disabled
/// ATT is not required for App Store if you don't use IDFA
class AppTrackingService {
  static TrackingStatus _status = TrackingStatus.notSupported;

  /// Get current tracking status
  static TrackingStatus get status => _status;

  /// Check if tracking is authorized
  static bool get isAuthorized => false;

  /// Initialize and request tracking permission (disabled)
  static Future<TrackingStatus> requestTrackingPermission() async {
    debugPrint('App Tracking: Disabled - not using IDFA');
    return TrackingStatus.notSupported;
  }

  /// Get the advertising identifier (always null when disabled)
  static Future<String?> getAdvertisingIdentifier() async {
    return null;
  }

  /// Check if we should show personalized ads
  static bool get canShowPersonalizedAds => false;

  /// Get human-readable status description
  static String get statusDescription => 'Not Supported';
}
