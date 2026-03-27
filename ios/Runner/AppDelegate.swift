import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let envPath = Bundle.main.path(forResource: ".env", ofType: nil, inDirectory: "flutter_assets") {
      if let envContent = try? String(contentsOfFile: envPath) {
        let lines = envContent.components(separatedBy: .newlines)
        for line in lines {
          let parts = line.components(separatedBy: "=")
          if parts.count >= 2, parts[0].trimmingCharacters(in: .whitespaces) == "GOOGLE_MAPS_API_KEY" {
            let key = parts.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespaces)
            GMSServices.provideAPIKey(key)
          }
        }
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
