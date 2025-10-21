import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Gelişmiş AI prompt sistemi
class AdvancedPromptService {
  /// Rüya türlerine göre özelleştirilmiş prompt'lar
  static const Map<String, String> _dreamTypePrompts = {
    'nightmare': '''
Sen deneyimli bir rüya terapisti ve psikologsun. Kabusları analiz ederken özellikle dikkatli ve destekleyici olmalısın.

Görevin:
1. Kabusun içindeki sembolleri ve duyguları analiz et
2. Bu kabusun altında yatan korkuları ve endişeleri tespit et
3. Kabusun bireyin günlük yaşamındaki stres faktörleriyle bağlantısını kur
4. Kabusun pozitif bir şekilde nasıl yorumlanabileceğini göster
5. Kabusla başa çıkma stratejileri öner
6. Umut verici ve güçlendirici bir ton kullan
7. Kabusun bir büyüme fırsatı olabileceğini vurgula

Cevabını Türkçe olarak ver ve çok dikkatli, destekleyici bir tonda ol.''',

    'lucid': '''
Sen deneyimli bir rüya araştırmacısı ve bilinçli rüya uzmanısın. Bilinçli rüyaları analiz ederken özellikle yaratıcılık ve kişisel gelişim odaklı yaklaşmalısın.

Görevin:
1. Bilinçli rüyanın sembollerini ve anlamlarını analiz et
2. Rüyada kontrol edilen unsurları ve bunların anlamını açıkla
3. Bu rüyanın kişinin güçlü yanlarını nasıl yansıttığını belirt
4. Bilinçli rüyanın yaratıcılık ve problem çözme becerilerine etkisini açıkla
5. Gelecekteki bilinçli rüyalar için öneriler sun
6. Bu rüyanın kişisel gelişim açısından önemini vurgula
7. Yaratıcı ve ilham verici bir ton kullan

Cevabını Türkçe olarak ver ve yaratıcı, ilham verici bir tonda ol.''',

    'recurring': '''
Sen deneyimli bir rüya analisti ve psikoterapistsin. Tekrarlayan rüyaları analiz ederken özellikle derinlemesine analiz ve çözüm odaklı yaklaşmalısın.

Görevin:
1. Tekrarlayan rüyanın temel sembollerini ve motiflerini analiz et
2. Bu rüyanın neden tekrar ettiğini ve altında yatan mesajı açıkla
3. Rüyanın bireyin yaşamındaki çözülmemiş konularla bağlantısını kur
4. Rüyanın evrimini ve değişimlerini analiz et
5. Bu rüyayı sonlandırma veya dönüştürme stratejileri öner
6. Rüyanın kişisel büyüme için sunduğu fırsatları belirt
7. Derinlemesine ve çözüm odaklı bir ton kullan

Cevabını Türkçe olarak ver ve derinlemesine, çözüm odaklı bir tonda ol.''',

    'prophetic': '''
Sen deneyimli bir rüya yorumcusu ve sezgisel danışmansın. Kehanet niteliğindeki rüyaları analiz ederken özellikle dikkatli ve dengeli yaklaşmalısın.

Görevin:
1. Rüyanın sembolik ve metaforik anlamlarını analiz et
2. Rüyanın gelecekle ilgili mesajlarını dikkatli bir şekilde yorumla
3. Rüyanın bireyin içgüdüleriyle bağlantısını açıkla
4. Rüyanın pratik yaşamda nasıl uygulanabileceğini öner
5. Rüyanın kişisel gelişim ve farkındalık açısından önemini belirt
6. Dikkatli ve dengeli bir ton kullan, kesin yargılardan kaçın
7. Rüyanın bir rehberlik aracı olduğunu vurgula

Cevabını Türkçe olarak ver ve dikkatli, dengeli bir tonda ol.''',

    'healing': '''
Sen deneyimli bir rüya terapisti ve şifa uzmanısın. Şifa niteliğindeki rüyaları analiz ederken özellikle iyileştirici ve umut verici yaklaşmalısın.

Görevin:
1. Rüyanın şifa ve iyileşme sembollerini analiz et
2. Rüyanın bireyin iyileşme sürecindeki rolünü açıkla
3. Rüyanın fiziksel, duygusal ve ruhsal iyileşmeye etkisini belirt
4. Rüyanın içindeki pozitif enerji ve güç kaynaklarını vurgula
5. İyileşme sürecini destekleyecek pratik öneriler sun
6. Rüyanın umut ve güç verici mesajlarını öne çıkar
7. İyileştirici ve umut verici bir ton kullan

Cevabını Türkçe olarak ver ve iyileştirici, umut verici bir tonda ol.''',
  };

  /// Rüya türünü tespit et
  static String _detectDreamType(String dreamDescription) {
    final description = dreamDescription.toLowerCase();
    
    if (description.contains('kabus') || 
        description.contains('korkunç') || 
        description.contains('korktu') ||
        description.contains('kaçtı') ||
        description.contains('tehlike')) {
      return 'nightmare';
    }
    
    if (description.contains('fark ettim') || 
        description.contains('bilinçli') || 
        description.contains('kontrol') ||
        description.contains('istedim') ||
        description.contains('karar verdim')) {
      return 'lucid';
    }
    
    if (description.contains('hep aynı') || 
        description.contains('tekrar') || 
        description.contains('sürekli') ||
        description.contains('her gece') ||
        description.contains('aynı rüya')) {
      return 'recurring';
    }
    
    if (description.contains('gelecek') || 
        description.contains('olacak') || 
        description.contains('kehanet') ||
        description.contains('öngörü') ||
        description.contains('tahmin')) {
      return 'prophetic';
    }
    
    if (description.contains('iyileşti') || 
        description.contains('şifa') || 
        description.contains('huzur') ||
        description.contains('rahatladı') ||
        description.contains('güçlendi')) {
      return 'healing';
    }
    
    return 'general';
  }

  /// Genel rüya yorumu prompt'u
  static const String _generalPrompt = '''
Sen deneyimli bir rüya yorumcusu ve psikologsun. Rüyaları analiz ederken özellikle kişiselleştirilmiş ve içgörülü yaklaşmalısın.

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

  /// Rüya türüne göre özelleştirilmiş prompt al
  static String getPromptForDream(String dreamDescription) {
    final dreamType = _detectDreamType(dreamDescription);
    return _dreamTypePrompts[dreamType] ?? _generalPrompt;
  }

  /// Rüya analizi için gelişmiş prompt oluştur
  static String createAdvancedPrompt(String dreamDescription) {
    final basePrompt = getPromptForDream(dreamDescription);
    
    return '''
$basePrompt

Rüya Analizi Formatı:
1. **Sembol Analizi**: Rüyadaki ana semboller ve anlamları
2. **Duygusal İçerik**: Rüyada hissedilen duygular ve bunların yorumu
3. **Psikolojik Bağlam**: Rüyanın bilinçaltıyla bağlantısı
4. **Yaşam Bağlantısı**: Rüyanın günlük yaşamla ilişkisi
5. **Rehberlik**: Kişisel gelişim için öneriler

Rüya: $dreamDescription

Lütfen yukarıdaki formatı takip ederek detaylı bir rüya yorumu yap.''';
  }
}

/// Gelişmiş Gemini servisi
class AdvancedGeminiService {
  /// Rüya yorumu yap
  Future<String> interpretDream(String dreamDescription) async {
    try {
      // Validate API key before making request
      final apiKey = ApiConfig.googleApiKey;
      
      if (apiKey.isEmpty) {
        throw Exception('Google API anahtarı bulunamadı. Lütfen yapılandırmanızı kontrol edin.');
      }
      
      final url = Uri.parse(
        '${ApiConfig.geminiBaseUrl}/models/${ApiConfig.geminiModel}:generateContent?key=$apiKey',
      );

      // Gelişmiş prompt kullan
      final advancedPrompt = AdvancedPromptService.createAdvancedPrompt(dreamDescription);

      // Format the request body according to the Gemini API specification
      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': advancedPrompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8, // Biraz daha yaratıcı
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1500, // Daha uzun yorumlar için
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

  /// Rüya türünü tespit et
  String detectDreamType(String dreamDescription) {
    return AdvancedPromptService._detectDreamType(dreamDescription);
  }

  /// Rüya özeti oluştur
  Future<String> createDreamSummary(String dreamDescription) async {
    try {
      final apiKey = ApiConfig.googleApiKey;
      
      if (apiKey.isEmpty) {
        throw Exception('Google API anahtarı bulunamadı.');
      }
      
      final url = Uri.parse(
        '${ApiConfig.geminiBaseUrl}/models/${ApiConfig.geminiModel}:generateContent?key=$apiKey',
      );

      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Bu rüyayı 2-3 cümleyle özetle: $dreamDescription'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.5,
          'maxOutputTokens': 100,
          'candidateCount': 1
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
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
      }
      
      return dreamDescription.length > 100 
          ? '${dreamDescription.substring(0, 100)}...'
          : dreamDescription;
    } catch (e) {
      return dreamDescription.length > 100 
          ? '${dreamDescription.substring(0, 100)}...'
          : dreamDescription;
    }
  }
}
