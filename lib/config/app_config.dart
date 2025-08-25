class AppConfig {
  // Development mode toggle - change this to switch modes
  static const bool isDevelopmentMode = true; // Set to false for production
  
  // Development mode settings
  static const bool useMockData = isDevelopmentMode;
  static const bool skipAuthentication = isDevelopmentMode;
  static const bool enableDebugFeatures = isDevelopmentMode;
  
  // Mock data settings
  static const String mockUserEmail = "dev@qingyue.com";
  static const String mockUserName = "开发者用户";
  static const String mockUserId = "mock_user_123";
  
  // Development shortcuts
  static const bool showDevPanel = isDevelopmentMode;
  static const bool enableQuickLogin = isDevelopmentMode;
  
  // Logging
  static const bool enableVerboseLogging = isDevelopmentMode;
  
  static void log(String message) {
    if (enableVerboseLogging) {
      print('[开发模式] $message');
    }
  }
}