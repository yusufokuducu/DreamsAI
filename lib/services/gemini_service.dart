import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GeminiService {
  static const String _systemPrompt = '''Sen deneyimli bir rüya yorumcususun. Rüyaların sembollerini, duygusal bağlamını ve bireysel yaşam durumlarını dikkate alarak anlamlı ve içgörülü yorumlar sunuyorsun. 

Görevin:
1. Rüyanın içeriğini semboller, renkler, duygular ve olaylar açısından analiz et
2. Rüyanın olası psikolojik ve duygusal anlamlarını açıkla
3. Rüyanın bireyin bilinçaltındaki düşünceleri, korkuları veya arzuları ile nasıl ilişkili olabileceğini belirt
4. Rüya sembollerinin evrensel anlamlarını ve bireysel bağlamı dengede sun
5. Anlamlı ve motive edici bir şekilde yorum yap, korkutucu ya da negatif olmaktan kaçın
6. Kısa, net ve anlaşılır bir dil kullan
7. Rüya yorumunun sonunda bireye rehberlik edici bir öneri veya düşünmesi gereken bir nokta sun
8. Cevabını Türkçe olarak ver ve genel olarak olumlu, teşvik edici bir tonda olmalı

Sadece rüya yorumunu ver, başka hiçbir şey ekleme.''';

  Future<String> interpretDream(String dreamDescription) async {
    try {
      // Validate API key before making request
      final apiKey = ApiConfig.googleApiKey;
      
      // API anahtarının boş olup olmadığını kontrol et
      if (apiKey.isEmpty) {
        throw Exception('Google API anahtarı bulunamadı. Lütfen yapılandırmanızı kontrol edin.');
      }
      
      final url = Uri.parse(
        '${ApiConfig.geminiBaseUrl}/models/${ApiConfig.geminiModel}:generateContent?key=$apiKey',
      );

      // Format the request body according to the Gemini API specification
      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$_systemPrompt\n\nRüya: $dreamDescription'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
          'candidateCount': 1
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        // Check for errors in the response first
        if (responseBody.containsKey('error')) {
          final error = responseBody['error'] as Map<String, dynamic>;
          throw Exception('API hatası: ${error['message']} (${error['code']})');
        }
        
        // Check if there are candidates in the response
        if (responseBody.containsKey('candidates') && responseBody['candidates'] is List && responseBody['candidates'].length > 0) {
          final candidates = responseBody['candidates'] as List;
          final candidate = candidates[0] as Map<String, dynamic>;
          
          if (candidate.containsKey('content') && candidate['content'] is Map) {
            final content = candidate['content'] as Map<String, dynamic>;
            
            if (content.containsKey('parts') && content['parts'] is List && content['parts'].length > 0) {
              final parts = content['parts'] as List;
              if (parts[0] is Map && (parts[0] as Map)['text'] != null) {
                return (parts[0] as Map)['text'] as String;
              }
            }
          }
        }
        
        throw Exception('Yapay zekadan gelen yanıtta bir sorun oluştu. Lütfen tekrar deneyin.');
      } else {
        // Handle non-200 responses
        String errorMessage = 'Yorumlama servisinde bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
        // Check for a common API key error
        if (response.body.toLowerCase().contains('api key not valid')) {
          errorMessage = 'API anahtarınız geçersiz görünüyor. Lütfen yapılandırmanızı kontrol edin.';
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Yanıt formatı hatası. Lütfen daha sonra tekrar deneyin.');
    } on http.ClientException {
      throw Exception('Ağ bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.');
    } catch (e) {
      // Rethrow exceptions that are already user-friendly.
      if (e is Exception) {
        final msg = e.toString();
        if (msg.contains('API anahtarı') || 
            msg.contains('Ağ bağlantı') || 
            msg.contains('Yorumlama servisi') || 
            msg.contains('Yapay zekadan')) {
          rethrow;
        }
      }
      // For any other unexpected error, throw a generic message.
      throw Exception('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }
}