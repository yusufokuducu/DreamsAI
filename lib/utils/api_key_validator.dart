class ApiKeyValidator {
  /// Validates if the provided API key follows the expected format for Google API
  static bool isValidApiKey(String apiKey) {
    // Google API keys typically start with "AIza" and have a specific format
    // Format: AIzaXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    if (apiKey.isEmpty) return false;
    
    // Check if it starts with "AIza"
    if (!apiKey.startsWith('AIza')) return false;
    
    // Check minimum length (Google API keys are typically 39 characters)
    if (apiKey.length < 35) return false;
    
    return true;
  }
  
  /// Returns true if API key is valid, false otherwise
  static bool validateApiKey() {
    // Use the API key from the config
    final apiKey = String.fromEnvironment('GOOGLE_API_KEY', 
        defaultValue: 'AIzaSyDUF2gnrZ0vnesGc_H1SahBGb2QZRPtJlU');
    
    return isValidApiKey(apiKey);
  }
}