import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dreams AI Integration Tests', () {
    testWidgets('Tam rüya yorumlama akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Ana ekranın yüklendiğini kontrol et
      expect(find.text('Rüya Yorumla'), findsOneWidget);

      // Rüya metni gir
      await tester.enterText(
        find.byType(TextField),
        'Uçtuğumu gördüm rüyamda. Gökyüzünde özgürce süzülüyordum.',
      );
      await tester.pump();

      // Yorumla butonuna bas
      await tester.tap(find.text('Yorumla'));
      await tester.pumpAndSettle();

      // Animasyonların çalıştığını kontrol et
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // API çağrısı simülasyonu için bekle
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Sonuç ekranının açıldığını kontrol et
      expect(find.text('Rüya Yorumu'), findsOneWidget);
      expect(find.text('Paylaş'), findsOneWidget);
      expect(find.text('Yeni Rüya'), findsOneWidget);
    });

    testWidgets('Paylaşım akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Rüya metni gir ve yorumla
      await tester.enterText(
        find.byType(TextField),
        'Denizde yüzüyordum rüyamda.',
      );
      await tester.tap(find.text('Yorumla'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Paylaş butonuna bas
      await tester.tap(find.text('Paylaş'));
      await tester.pumpAndSettle();

      // Paylaşım ekranının açıldığını kontrol et
      expect(find.text('Paylaşım Önizlemesi'), findsOneWidget);
      expect(find.text('Paylaşım Platformu Seçin'), findsOneWidget);

      // Platform seçimi
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('Twitter'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });

    testWidgets('Premium akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // FAB'a basarak Premium ekranına git
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Premium ekranının açıldığını kontrol et
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Premium Paketler'), findsOneWidget);

      // Paket kartlarının görünür olduğunu kontrol et
      expect(find.text('7 Rüya Paketi'), findsOneWidget);
      expect(find.text('14 Rüya Paketi'), findsOneWidget);
      expect(find.text('21 Rüya Paketi'), findsOneWidget);
      expect(find.text('28 Rüya Paketi'), findsOneWidget);

      // Geri dön
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Ana ekrana döndüğünü kontrol et
      expect(find.text('Rüya Yorumla'), findsOneWidget);
    });

    testWidgets('Geçmiş ekranı akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Geçmiş tab'ına geç
      await tester.tap(find.text('Geçmiş'));
      await tester.pumpAndSettle();

      // Geçmiş ekranının açıldığını kontrol et
      expect(find.text('Geçmiş'), findsOneWidget);

      // Boş durum mesajını kontrol et
      expect(find.text('Henüz rüya yok'), findsOneWidget);
      expect(find.text('Yorumlanan rüyalar burada görünecek'), findsOneWidget);
    });

    testWidgets('Profil ekranı akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Profil tab'ına geç
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Profil ekranının açıldığını kontrol et
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Dreams AI'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Uygulama'), findsOneWidget);

      // Bildirimler switch'ini kontrol et
      expect(find.byType(Switch), findsOneWidget);

      // Hakkında butonuna bas
      await tester.tap(find.text('Hakkında'));
      await tester.pumpAndSettle();

      // Hakkında dialog'unun açıldığını kontrol et
      expect(find.text('Dreams AI'), findsAtLeastNWidgets(1));
    });

    testWidgets('Limit kontrolü akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // 3 rüya yorumu simüle et (limit testi için)
      for (int i = 0; i < 3; i++) {
        await tester.enterText(
          find.byType(TextField),
          'Test rüyası $i',
        );
        await tester.tap(find.text('Yorumla'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Sonuç ekranından geri dön
        await tester.tap(find.text('Yeni Rüya'));
        await tester.pumpAndSettle();
      }

      // 4. rüya yorumu denemesi
      await tester.enterText(
        find.byType(TextField),
        'Limit test rüyası',
      );
      await tester.tap(find.text('Yorumla'));
      await tester.pumpAndSettle();

      // Limit aşımı dialog'unun açıldığını kontrol et
      expect(find.text('Haftalık Limit Doldu'), findsOneWidget);
      expect(find.text('Premium\'a Geç'), findsOneWidget);
    });

    testWidgets('Animasyon akışı', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Rüya metni gir
      await tester.enterText(
        find.byType(TextField),
        'Animasyon test rüyası',
      );
      await tester.pump();

      // Karakter animasyonunun başladığını kontrol et
      expect(find.byType(AnimatedCharacter), findsOneWidget);

      // Yorumla butonuna bas
      await tester.tap(find.text('Yorumla'));
      await tester.pump();

      // Küre animasyonunun başladığını kontrol et
      expect(find.byType(MagicSphere), findsOneWidget);

      // Loading animasyonunun görünür olduğunu kontrol et
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Responsive tasarım testi', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Farklı ekran boyutlarında test et
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // Ana elementlerin görünür olduğunu kontrol et
      expect(find.text('Rüya Yorumla'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Daha küçük ekran boyutu
      await tester.binding.setSurfaceSize(const Size(300, 600));
      await tester.pumpAndSettle();

      // Elementlerin hala görünür olduğunu kontrol et
      expect(find.text('Rüya Yorumla'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Hata yönetimi testi', (WidgetTester tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle();

      // Geçersiz metin gir (çok uzun)
      await tester.enterText(
        find.byType(TextField),
        'A' * 10000, // Çok uzun metin
      );
      await tester.tap(find.text('Yorumla'));
      await tester.pumpAndSettle();

      // Uygulamanın çökmediğini kontrol et
      expect(find.text('Rüya Yorumla'), findsOneWidget);
    });
  });
}
