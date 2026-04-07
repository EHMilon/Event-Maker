/// App configuration constants
class AppConfig {
  // Google Maps API Key
  // Note: This key is also configured in:
  // - Android: android/app/src/main/AndroidManifest.xml (via Gradle injection from .env)
  // - The .env file contains: GOOGLE_MAPS_API_KEY=your_key_here
  static String get googleMapsApiKey {
    // Return the API key from .env file
    // For security, this should match the key in your .env file
    return 'AIzaSyDUG5-oxWq1CeJRKcMMJ69AstZhiscurv0';
  }
}
