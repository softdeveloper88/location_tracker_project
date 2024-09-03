import Flutter
import UIKit
import flutter_background_service_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
 
      SwiftFlutterBackgroundServicePlugin.taskIdentifier = "dev.flutter.background.refresh"
   
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
           let batteryChannel = FlutterMethodChannel(name: "flutter.native/helper",
                                                   binaryMessenger: controller.binaryMessenger)
      batteryChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          if (call.method == "PhoneDeviceId") {
              let deviceId = UIDevice.current.identifierForVendor?.uuidString
              result(deviceId)
              return
          }
      })
         
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
