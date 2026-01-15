import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// App Tracking Transparency Service
/// Required for iOS 14+ App Store compliance
class AppTrackingService {
  static TrackingStatus _status = TrackingStatus.notDetermined;

  /// Get current tracking status
  static TrackingStatus get status => _status;

  /// Check if tracking is authorized
  static bool get isAuthorized => _status == TrackingStatus.authorized;

  /// Initialize and request tracking permission
  /// Call this when the app starts (after splash screen)
  static Future<TrackingStatus> requestTrackingPermission() async {
    if (!Platform.isIOS) {
      // Not needed for non-iOS platforms
      return TrackingStatus.notSupported;
    }

    try {
      // First check current status
      _status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // If not determined yet, request permission
      if (_status == TrackingStatus.notDetermined) {
        // Wait a bit before showing the dialog (Apple recommends this)
        await Future.delayed(const Duration(milliseconds: 500));

        _status = await AppTrackingTransparency.requestTrackingAuthorization();
      }

      debugPrint('App Tracking Status: $_status');
      return _status;
    } catch (e) {
      debugPrint('Error requesting tracking permission: $e');
      return TrackingStatus.notSupported;
    }
  }

  /// Get the advertising identifier (IDFA)
  /// Only available if tracking is authorized
  static Future<String?> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) return null;

    if (_status == TrackingStatus.authorized) {
      try {
        final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
        return uuid.isNotEmpty ? uuid : null;
      } catch (e) {
        debugPrint('Error getting advertising identifier: $e');
        return null;
      }
    }
    return null;
  }

  /// Check if we should show personalized ads
  static bool get canShowPersonalizedAds =>
      _status == TrackingStatus.authorized;

  /// Get human-readable status description
  static String get statusDescription {
    switch (_status) {
      case TrackingStatus.notDetermined:
        return 'Not Determined';
      case TrackingStatus.restricted:
        return 'Restricted';
      case TrackingStatus.denied:
        return 'Denied';
      case TrackingStatus.authorized:
        return 'Authorized';
      case TrackingStatus.notSupported:
        return 'Not Supported';
    }
  }
}
