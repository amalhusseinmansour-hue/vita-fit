import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins first
    GeneratedPluginRegistrant.register(with: self)

    // Call super first to let Flutter initialize
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Setup notification delegate after Flutter is ready
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return result
  }
}
