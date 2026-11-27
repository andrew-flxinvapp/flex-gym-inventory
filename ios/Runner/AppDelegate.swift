import Flutter
import StoreKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "flex_gym_inventory/subscription_management",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "showManageSubscriptions" else {
        result(FlutterMethodNotImplemented)
        return
      }
      Task { @MainActor in
        guard let scene = UIApplication.shared.connectedScenes
          .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
          result(FlutterError(code: "unavailable", message: "Subscription management is unavailable.", details: nil))
          return
        }
        do {
          try await AppStore.showManageSubscriptions(in: scene)
          result(nil)
        } catch {
          result(FlutterError(code: "unavailable", message: "Subscription management is unavailable.", details: nil))
        }
      }
    }
  }
}
