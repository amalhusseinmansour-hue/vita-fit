class ApiConfig {
  // Connection modes:
  // - 'demo': Demo mode with offline data (no server needed)
  // - 'production': Production server (vitafit.online)
  // - 'emulator': For Android Emulator (uses 10.0.2.2)
  // - 'wifi': For Physical Device on same WiFi (uses local IP)
  // - 'usb': For Physical Device with USB Tethering (uses 192.168.42.x)
  // - 'web': For Web Browser (uses localhost)
  static const String connectionMode = 'production'; // Change to: 'demo', 'production', 'emulator', 'wifi', 'usb', or 'web'

  // API Base URLs
  static const String productionBaseUrl = 'https://vitafit.online/api';  // Production server
  static const String emulatorBaseUrl = 'http://10.0.2.2:5000/api';  // For Android Emulator
  static const String wifiBaseUrl = 'http://192.168.1.9:5000/api';  // For WiFi connection
  static const String usbTetheringBaseUrl = 'http://192.168.42.129:5000/api';  // For USB Tethering (gateway IP)
  static const String webBaseUrl = 'http://localhost:5000/api';  // For Web Browser

  // Get the appropriate base URL based on connection mode
  static String get baseUrl {
    switch (connectionMode) {
      case 'production':
        return productionBaseUrl;
      case 'emulator':
        return emulatorBaseUrl;
      case 'wifi':
        return wifiBaseUrl;
      case 'usb':
        return usbTetheringBaseUrl;
      case 'web':
        return webBaseUrl;
      default:
        return productionBaseUrl; // Default to production
    }
  }

  // Timeout configuration
  static const Duration timeout = Duration(seconds: 30);

  // Check if in demo mode
  static bool get isDemoMode => connectionMode == 'demo';
}
