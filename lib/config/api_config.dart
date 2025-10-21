import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Google Gemini API configuration
  static String get googleApiKey {
    return dotenv.env['GOOGLE_API_KEY'] ?? '';
  }
  
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-1.5-flash'; // Using gemini-1.5-flash model for text generation
}