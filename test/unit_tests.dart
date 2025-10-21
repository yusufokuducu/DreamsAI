import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/limit_service.dart';
import '../lib/services/performance_service.dart';

void main() {
  group('LimitService Tests', () {
    setUp(() async {
      // Her test öncesi SharedPreferences'ı temizle
      SharedPreferences.setMockInitialValues({});
      await LimitService.resetLimitForTesting();
    });

    test('Haftalık limit kontrolü - başlangıçta 3 limit olmalı', () async {
      final limit = await LimitService.getWeeklyLimit();
      expect(limit, equals(3));
    });

    test('Kullanılan rüya sayısı - başlangıçta 0 olmalı', () async {
      final used = await LimitService.getUsedDreamsThisWeek();
      expect(used, equals(0));
    });

    test('Kalan rüya sayısı - başlangıçta 3 olmalı', () async {
      final remaining = await LimitService.getRemainingDreamsThisWeek();
      expect(remaining, equals(3));
    });

    test('Rüya yorumu kullanımı - başarılı olmalı', () async {
      final success = await LimitService.useDreamInterpretation();
      expect(success, isTrue);
      
      final used = await LimitService.getUsedDreamsThisWeek();
      expect(used, equals(1));
    });

    test('Limit aşımı kontrolü - 3 kullanımdan sonra limit dolmalı', () async {
      // 3 rüya yorumu kullan
      for (int i = 0; i < 3; i++) {
        await LimitService.useDreamInterpretation();
      }
      
      final remaining = await LimitService.getRemainingDreamsThisWeek();
      expect(remaining, equals(0));
      
      // 4. kullanım başarısız olmalı
      final success = await LimitService.useDreamInterpretation();
      expect(success, isFalse);
    });

    test('Premium paket satın alma - limit artmalı', () async {
      await LimitService.purchasePackage('dreams_7');
      
      final isPremium = await LimitService.isPremiumUser();
      expect(isPremium, isTrue);
      
      final limit = await LimitService.getWeeklyLimit();
      expect(limit, equals(10)); // 3 + 7
    });

    test('Limit durumu istatistikleri', () async {
      await LimitService.useDreamInterpretation();
      
      final status = await LimitService.getLimitStatus();
      expect(status['used'], equals(1));
      expect(status['limit'], equals(3));
      expect(status['remaining'], equals(2));
      expect(status['isPremium'], equals(false));
      expect(status['isLimitReached'], equals(false));
    });
  });

  group('PerformanceService Tests', () {
    setUp(() {
      PerformanceService.clearStats();
    });

    test('İşlem süre ölçümü', () {
      PerformanceService.startOperation('test_operation');
      
      // Kısa bir gecikme simüle et
      Future.delayed(const Duration(milliseconds: 100), () {
        PerformanceService.endOperation('test_operation');
      });
      
      // İstatistikleri kontrol et
      final stats = PerformanceService.getPerformanceStats();
      expect(stats.containsKey('test_operation'), isTrue);
    });

    test('Ortalama süre hesaplama', () {
      // Birden fazla ölçüm ekle
      PerformanceService.startOperation('test_operation');
      PerformanceService.endOperation('test_operation');
      
      PerformanceService.startOperation('test_operation');
      PerformanceService.endOperation('test_operation');
      
      final averageDuration = PerformanceService.getAverageDuration('test_operation');
      expect(averageDuration, isNotNull);
    });

    test('Performans istatistikleri temizleme', () {
      PerformanceService.startOperation('test_operation');
      PerformanceService.endOperation('test_operation');
      
      PerformanceService.clearStats();
      
      final stats = PerformanceService.getPerformanceStats();
      expect(stats.isEmpty, isTrue);
    });
  });

  group('ApiCacheService Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ApiCacheService.clearCache();
    });

    test('Rüya yorumu önbellekleme', () async {
      const dreamDescription = 'Test rüyası';
      const interpretation = 'Test yorumu';
      
      await ApiCacheService.cacheDreamInterpretation(dreamDescription, interpretation);
      
      final cached = await ApiCacheService.getCachedDreamInterpretation(dreamDescription);
      expect(cached, equals(interpretation));
    });

    test('Önbellek istatistikleri', () async {
      await ApiCacheService.cacheDreamInterpretation('Test 1', 'Yorum 1');
      await ApiCacheService.cacheDreamInterpretation('Test 2', 'Yorum 2');
      
      final stats = await ApiCacheService.getCacheStats();
      expect(stats['totalCached'], equals(2));
      expect(stats['totalSize'], greaterThan(0));
    });

    test('Önbellek temizleme', () async {
      await ApiCacheService.cacheDreamInterpretation('Test', 'Yorum');
      
      await ApiCacheService.clearCache();
      
      final cached = await ApiCacheService.getCachedDreamInterpretation('Test');
      expect(cached, isNull);
    });

    test('Süresi dolmuş önbellek temizleme', () async {
      // Eski bir timestamp ile önbellek oluştur
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'dream_cache_test';
      final timestampKey = 'dream_timestamp_test';
      
      await prefs.setString(cacheKey, 'Yorum');
      await prefs.setString(timestampKey, DateTime.now().subtract(const Duration(hours: 25)).toIso8601String());
      
      // Süresi dolmuş önbellekleri temizle
      await ApiCacheService.cleanExpiredCache();
      
      final cached = await ApiCacheService.getCachedDreamInterpretation('Test');
      expect(cached, isNull);
    });
  });

  group('MemoryLeakDetector Tests', () {
    test('Nesne sayısı kaydetme', () {
      MemoryLeakDetector.recordObjectCount('TestObject', 50);
      
      final stats = MemoryLeakDetector.getMemoryStats();
      expect(stats['objectCounts']['TestObject'], equals(50));
    });

    test('Memory leak kontrolü', () {
      MemoryLeakDetector.recordObjectCount('TestObject', 150);
      
      final leaks = MemoryLeakDetector.checkForLeaks();
      expect(leaks.containsKey('TestObject'), isTrue);
    });
  });
}
