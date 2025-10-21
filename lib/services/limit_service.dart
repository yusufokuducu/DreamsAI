import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Haftalık limit kontrolü servisi
class LimitService {
  static const String _weeklyLimitKey = 'weekly_dream_limit';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _totalDreamsKey = 'total_dreams_this_week';
  static const String _premiumUserKey = 'is_premium_user';
  static const String _purchasedPackagesKey = 'purchased_packages';
  
  static const int _freeWeeklyLimit = 3;
  
  /// Haftalık limit paketleri
  static const Map<String, int> _packages = {
    'dreams_7': 7,    // $4
    'dreams_14': 14,  // $8
    'dreams_21': 21,  // $12
    'dreams_28': 28,  // $16
  };

  /// Kullanıcının bu hafta kaç rüya yorumladığını döndürür
  static Future<int> getUsedDreamsThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString(_lastResetDateKey);
    final now = DateTime.now();
    
    // Eğer hiç reset tarihi yoksa veya hafta geçmişse, sıfırla
    if (lastResetDate == null || _shouldResetWeek(lastResetDate, now)) {
      await _resetWeeklyLimit(now);
      return 0;
    }
    
    return prefs.getInt(_totalDreamsKey) ?? 0;
  }

  /// Kullanıcının bu hafta kaç rüya yorumlama hakkı kaldığını döndürür
  static Future<int> getRemainingDreamsThisWeek() async {
    final used = await getUsedDreamsThisWeek();
    final limit = await getWeeklyLimit();
    return (limit - used).clamp(0, limit);
  }

  /// Haftalık limiti döndürür (ücretsiz veya premium)
  static Future<int> getWeeklyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumUserKey) ?? false;
    
    if (isPremium) {
      // Premium kullanıcı için satın alınan paketlerin toplamını hesapla
      final purchasedPackages = prefs.getStringList(_purchasedPackagesKey) ?? [];
      int totalLimit = _freeWeeklyLimit;
      
      for (final package in purchasedPackages) {
        if (_packages.containsKey(package)) {
          totalLimit += _packages[package]!;
        }
      }
      
      return totalLimit;
    }
    
    return _freeWeeklyLimit;
  }

  /// Yeni bir rüya yorumlandığında çağrılır
  static Future<bool> useDreamInterpretation() async {
    final remaining = await getRemainingDreamsThisWeek();
    
    if (remaining <= 0) {
      return false; // Limit aşıldı
    }
    
    final prefs = await SharedPreferences.getInstance();
    final currentUsed = prefs.getInt(_totalDreamsKey) ?? 0;
    await prefs.setInt(_totalDreamsKey, currentUsed + 1);
    
    return true; // Başarılı
  }

  /// Premium kullanıcı mı kontrol eder
  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumUserKey) ?? false;
  }

  /// Premium paket satın alındığında çağrılır
  static Future<void> purchasePackage(String packageId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Premium kullanıcı olarak işaretle
    await prefs.setBool(_premiumUserKey, true);
    
    // Satın alınan paketi ekle
    final purchasedPackages = prefs.getStringList(_purchasedPackagesKey) ?? [];
    if (!purchasedPackages.contains(packageId)) {
      purchasedPackages.add(packageId);
      await prefs.setStringList(_purchasedPackagesKey, purchasedPackages);
    }
  }

  /// Haftalık limiti sıfırla
  static Future<void> _resetWeeklyLimit(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalDreamsKey, 0);
    await prefs.setString(_lastResetDateKey, now.toIso8601String());
  }

  /// Hafta geçmiş mi kontrol eder
  static bool _shouldResetWeek(String lastResetDateString, DateTime now) {
    try {
      final lastResetDate = DateTime.parse(lastResetDateString);
      final daysDifference = now.difference(lastResetDate).inDays;
      
      // Pazartesi günü hafta başlangıcı olarak kabul edilir
      final lastMonday = _getLastMonday(lastResetDate);
      final currentMonday = _getLastMonday(now);
      
      return currentMonday.isAfter(lastMonday);
    } catch (e) {
      return true; // Parse hatası durumunda sıfırla
    }
  }

  /// Verilen tarihten önceki pazartesi gününü döndürür
  static DateTime _getLastMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday == 1 ? 0 : weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Limit durumu bilgilerini döndürür
  static Future<Map<String, dynamic>> getLimitStatus() async {
    final used = await getUsedDreamsThisWeek();
    final limit = await getWeeklyLimit();
    final remaining = limit - used;
    final isPremium = await isPremiumUser();
    
    return {
      'used': used,
      'limit': limit,
      'remaining': remaining.clamp(0, limit),
      'isPremium': isPremium,
      'isLimitReached': remaining <= 0,
    };
  }

  /// Paket bilgilerini döndürür
  static Map<String, Map<String, dynamic>> getPackageInfo() {
    return {
      'dreams_7': {
        'name': '7 Rüya Paketi',
        'price': '\$4',
        'dreams': 7,
        'description': 'Haftalık 7 ek rüya yorumu',
      },
      'dreams_14': {
        'name': '14 Rüya Paketi',
        'price': '\$8',
        'dreams': 14,
        'description': 'Haftalık 14 ek rüya yorumu',
      },
      'dreams_21': {
        'name': '21 Rüya Paketi',
        'price': '\$12',
        'dreams': 21,
        'description': 'Haftalık 21 ek rüya yorumu',
      },
      'dreams_28': {
        'name': '28 Rüya Paketi',
        'price': '\$16',
        'dreams': 28,
        'description': 'Haftalık 28 ek rüya yorumu',
      },
    };
  }

  /// Debug için limit durumunu sıfırla
  static Future<void> resetLimitForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalDreamsKey);
    await prefs.remove(_lastResetDateKey);
    await prefs.remove(_premiumUserKey);
    await prefs.remove(_purchasedPackagesKey);
  }
}
