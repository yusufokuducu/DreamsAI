import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Sosyal medya paylaşım servisi
class ShareService {
  /// Genel paylaşım (sistem paylaşım menüsü)
  static Future<void> shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      debugPrint('Paylaşım hatası: $e');
    }
  }

  /// WhatsApp paylaşımı
  static Future<bool> shareToWhatsApp(String text) async {
    try {
      await Share.share(text, subject: 'Rüya Yorumu');
      return true;
    } catch (e) {
      debugPrint('WhatsApp paylaşım hatası: $e');
      return false;
    }
  }

  /// Facebook paylaşımı
  static Future<bool> shareToFacebook(String text) async {
    try {
      await Share.share(text, subject: 'Rüya Yorumu');
      return true;
    } catch (e) {
      debugPrint('Facebook paylaşım hatası: $e');
      return false;
    }
  }

  /// Twitter/X paylaşımı
  static Future<bool> shareToTwitter(String text) async {
    try {
      await Share.share(text, subject: 'Rüya Yorumu');
      return true;
    } catch (e) {
      debugPrint('Twitter paylaşım hatası: $e');
      return false;
    }
  }

  /// Instagram Story paylaşımı (sadece resim)
  static Future<bool> shareToInstagramStory(String imagePath) async {
    try {
      if (Platform.isAndroid) {
        // Android için Instagram Story paylaşımı
        // Bu özellik flutter_share_me paketinde mevcut olmayabilir
        // Alternatif olarak genel paylaşım kullanabiliriz
        // Instagram Story paylaşımı desteklenmiyor, genel paylaşım kullan
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Instagram Story paylaşım hatası: $e');
      return false;
    }
  }

  /// Telegram paylaşımı
  static Future<bool> shareToTelegram(String text) async {
    try {
      await Share.share(text, subject: 'Rüya Yorumu');
      return true;
    } catch (e) {
      debugPrint('Telegram paylaşım hatası: $e');
      return false;
    }
  }

  /// Rüya yorumu için özel paylaşım metni oluştur
  static String createDreamShareText(String dream, String interpretation) {
    return '''
🌟 Dreams AI ile rüyamı yorumladım! 

💭 Rüyam:
$dream

✨ Yorum:
$interpretation

#DreamsAI #RüyaYorumu #YapayZeka #Rüyalar
''';
  }

  /// Kısa paylaşım metni (Twitter için)
  static String createShortDreamShareText(String dream, String interpretation) {
    final shortDream = dream.length > 100 ? '${dream.substring(0, 100)}...' : dream;
    final shortInterpretation = interpretation.length > 150 ? '${interpretation.substring(0, 150)}...' : interpretation;
    
    return '''
🌟 Dreams AI ile rüyamı yorumladım!

💭 $shortDream

✨ $shortInterpretation

#DreamsAI #RüyaYorumu
''';
  }

  /// Instagram Story için metin
  static String createInstagramStoryText(String dream, String interpretation) {
    return '''
🌟 Dreams AI ile rüyamı yorumladım!

💭 Rüyam:
$dream

✨ Yorum:
$interpretation

#DreamsAI #RüyaYorumu #YapayZeka
''';
  }

  /// WhatsApp için metin
  static String createWhatsAppText(String dream, String interpretation) {
    return '''
🌟 *Dreams AI* ile rüyamı yorumladım! 

💭 *Rüyam:*
$dream

✨ *Yorum:*
$interpretation

_Dreams AI - Rüyalarınızı yapay zeka ile yorumlayın_
''';
  }
}