import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';

/// API yanıt önbellekleme servisi
class ApiCacheService {
  static const String _cachePrefix = 'dream_cache_';
  static const String _cacheTimestampPrefix = 'dream_timestamp_';
  static const int _cacheExpirationHours = 24; // 24 saat önbellek süresi

  /// Rüya yorumunu önbelleğe al
  static Future<void> cacheDreamInterpretation(
    String dreamDescription,
    String interpretation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(dreamDescription);
      final timestampKey = _generateTimestampKey(dreamDescription);
      
      await prefs.setString(cacheKey, interpretation);
      await prefs.setString(timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Önbellekleme hatası sessizce geç
      print('Cache error: $e');
    }
  }

  /// Önbellekten rüya yorumunu al
  static Future<String?> getCachedDreamInterpretation(String dreamDescription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(dreamDescription);
      final timestampKey = _generateTimestampKey(dreamDescription);
      
      final cachedInterpretation = prefs.getString(cacheKey);
      final timestampString = prefs.getString(timestampKey);
      
      if (cachedInterpretation == null || timestampString == null) {
        return null;
      }
      
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      final hoursDifference = now.difference(timestamp).inHours;
      
      // Önbellek süresi dolmuş mu kontrol et
      if (hoursDifference >= _cacheExpirationHours) {
        // Eski önbelleği temizle
        await prefs.remove(cacheKey);
        await prefs.remove(timestampKey);
        return null;
      }
      
      return cachedInterpretation;
    } catch (e) {
      // Önbellek okuma hatası sessizce geç
      print('Cache read error: $e');
      return null;
    }
  }

  /// Önbellek anahtarı oluştur
  static String _generateCacheKey(String dreamDescription) {
    final bytes = utf8.encode(dreamDescription.toLowerCase().trim());
    final digest = md5.convert(bytes);
    return '$_cachePrefix${digest.toString()}';
  }

  /// Timestamp anahtarı oluştur
  static String _generateTimestampKey(String dreamDescription) {
    final bytes = utf8.encode(dreamDescription.toLowerCase().trim());
    final digest = md5.convert(bytes);
    return '$_cacheTimestampPrefix${digest.toString()}';
  }

  /// Önbelleği temizle
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Önbellek istatistikleri
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int cacheCount = 0;
      int expiredCount = 0;
      int totalSize = 0;
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          cacheCount++;
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      // Süresi dolmuş önbellekleri say
      for (final key in keys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final timestampString = prefs.getString(key);
          if (timestampString != null) {
            final timestamp = DateTime.parse(timestampString);
            final hoursDifference = DateTime.now().difference(timestamp).inHours;
            if (hoursDifference >= _cacheExpirationHours) {
              expiredCount++;
            }
          }
        }
      }
      
      return {
        'totalCached': cacheCount,
        'expiredCount': expiredCount,
        'totalSize': totalSize,
        'expirationHours': _cacheExpirationHours,
      };
    } catch (e) {
      return {
        'totalCached': 0,
        'expiredCount': 0,
        'totalSize': 0,
        'expirationHours': _cacheExpirationHours,
        'error': e.toString(),
      };
    }
  }

  /// Eski önbellekleri temizle
  static Future<void> cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final timestampString = prefs.getString(key);
          if (timestampString != null) {
            final timestamp = DateTime.parse(timestampString);
            final hoursDifference = DateTime.now().difference(timestamp).inHours;
            
            if (hoursDifference >= _cacheExpirationHours) {
              // İlgili önbellek anahtarını da bul ve sil
              final cacheKey = key.replaceFirst(_cacheTimestampPrefix, _cachePrefix);
              await prefs.remove(key);
              await prefs.remove(cacheKey);
            }
          }
        }
      }
    } catch (e) {
      print('Cache cleanup error: $e');
    }
  }
}

/// Performans izleme servisi
class PerformanceService {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _durations = {};

  /// İşlem başlat
  static void startOperation(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// İşlem bitir
  static void endOperation(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      
      if (!_durations.containsKey(operationName)) {
        _durations[operationName] = [];
      }
      
      _durations[operationName]!.add(duration);
      
      // Son 100 ölçümü sakla
      if (_durations[operationName]!.length > 100) {
        _durations[operationName]!.removeAt(0);
      }
      
      _startTimes.remove(operationName);
    }
  }

  /// Ortalama süre al
  static Duration? getAverageDuration(String operationName) {
    final durations = _durations[operationName];
    if (durations == null || durations.isEmpty) {
      return null;
    }
    
    final totalMilliseconds = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: totalMilliseconds ~/ durations.length);
  }

  /// Performans istatistikleri
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final operationName in _durations.keys) {
      final durations = _durations[operationName]!;
      if (durations.isNotEmpty) {
        final totalMs = durations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMilliseconds,
        );
        
        stats[operationName] = {
          'count': durations.length,
          'averageMs': totalMs ~/ durations.length,
          'minMs': durations.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b),
          'maxMs': durations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b),
        };
      }
    }
    
    return stats;
  }

  /// Performans verilerini temizle
  static void clearStats() {
    _durations.clear();
    _startTimes.clear();
  }
}

/// Memory leak kontrolü
class MemoryLeakDetector {
  static final Map<String, int> _objectCounts = {};
  static final Map<String, DateTime> _lastCheckTimes = {};

  /// Nesne sayısını kaydet
  static void recordObjectCount(String objectType, int count) {
    _objectCounts[objectType] = count;
    _lastCheckTimes[objectType] = DateTime.now();
  }

  /// Memory leak kontrolü yap
  static Map<String, dynamic> checkForLeaks() {
    final leaks = <String, dynamic>{};
    
    for (final entry in _objectCounts.entries) {
      final objectType = entry.key;
      final count = entry.value;
      final lastCheck = _lastCheckTimes[objectType];
      
      if (lastCheck != null) {
        final hoursSinceLastCheck = DateTime.now().difference(lastCheck).inHours;
        
        // Eğer 1 saatten fazla süredir nesne sayısı yüksekse potansiyel leak
        if (hoursSinceLastCheck > 1 && count > 100) {
          leaks[objectType] = {
            'count': count,
            'hoursSinceLastCheck': hoursSinceLastCheck,
            'potentialLeak': true,
          };
        }
      }
    }
    
    return leaks;
  }

  /// Memory istatistikleri
  static Map<String, dynamic> getMemoryStats() {
    return {
      'objectCounts': Map.from(_objectCounts),
      'lastCheckTimes': Map.from(_lastCheckTimes),
      'potentialLeaks': checkForLeaks(),
    };
  }
}
