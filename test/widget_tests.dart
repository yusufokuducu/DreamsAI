import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/services/animation_service.dart';
import '../lib/services/payment_service.dart';
import '../lib/models/animation_state.dart';
import '../lib/widgets/animated_character.dart';
import '../lib/widgets/magic_sphere.dart';
import '../lib/widgets/share_card.dart';
import '../lib/screens/dream_input_screen.dart';
import '../lib/screens/premium_screen.dart';

void main() {
  group('AnimatedCharacter Widget Tests', () {
    testWidgets('AnimatedCharacter - idle durumunda görünür', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AnimationService(),
          child: const MaterialApp(
            home: Scaffold(
              body: AnimatedCharacter(),
            ),
          ),
        ),
      );

      // Widget'ın görünür olduğunu kontrol et
      expect(find.byType(AnimatedCharacter), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('AnimatedCharacter - thinking durumunda animasyon', (WidgetTester tester) async {
      final animationService = AnimationService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => animationService,
          child: const MaterialApp(
            home: Scaffold(
              body: AnimatedCharacter(),
            ),
          ),
        ),
      );

      // Thinking durumuna geç
      animationService.setCharacterState(AnimationState.thinking);
      await tester.pump();

      // Thinking ikonunun görünür olduğunu kontrol et
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('AnimatedCharacter - success durumunda animasyon', (WidgetTester tester) async {
      final animationService = AnimationService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => animationService,
          child: const MaterialApp(
            home: Scaffold(
              body: AnimatedCharacter(),
            ),
          ),
        ),
      );

      // Success durumuna geç
      animationService.setCharacterState(AnimationState.success);
      await tester.pump();

      // Success ikonunun görünür olduğunu kontrol et
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('MagicSphere Widget Tests', () {
    testWidgets('MagicSphere - hidden durumunda görünmez', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AnimationService(),
          child: const MaterialApp(
            home: Scaffold(
              body: MagicSphere(),
            ),
          ),
        ),
      );

      // Widget'ın görünmez olduğunu kontrol et
      expect(find.byType(MagicSphere), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
    });

    testWidgets('MagicSphere - appearing durumunda görünür', (WidgetTester tester) async {
      final animationService = AnimationService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => animationService,
          child: const MaterialApp(
            home: Scaffold(
              body: MagicSphere(),
            ),
          ),
        ),
      );

      // Appearing durumuna geç
      animationService.setSphereState(SphereAnimationState.appearing);
      await tester.pump();

      // Kürenin görünür olduğunu kontrol et
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });

  group('ShareCard Widget Tests', () {
    testWidgets('ShareCard - temel görünüm', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareCard(
              dream: 'Test rüyası',
              interpretation: 'Test yorumu',
            ),
          ),
        ),
      );

      // Widget'ın görünür olduğunu kontrol et
      expect(find.byType(ShareCard), findsOneWidget);
      expect(find.text('Test rüyası'), findsOneWidget);
      expect(find.text('Test yorumu'), findsOneWidget);
      expect(find.text('Dreams AI'), findsOneWidget);
    });

    testWidgets('ShareCard - Instagram stili', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareCard(
              dream: 'Test rüyası',
              interpretation: 'Test yorumu',
              style: ShareCardStyle.instagram,
            ),
          ),
        ),
      );

      // Widget'ın görünür olduğunu kontrol et
      expect(find.byType(ShareCard), findsOneWidget);
    });

    testWidgets('ShareCard - Facebook stili', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareCard(
              dream: 'Test rüyası',
              interpretation: 'Test yorumu',
              style: ShareCardStyle.facebook,
            ),
          ),
        ),
      );

      // Widget'ın görünür olduğunu kontrol et
      expect(find.byType(ShareCard), findsOneWidget);
    });
  });

  group('DreamInputScreen Widget Tests', () {
    testWidgets('DreamInputScreen - temel görünüm', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: DreamInputScreen(),
          ),
        ),
      );

      // Temel elementlerin görünür olduğunu kontrol et
      expect(find.text('Rüyanızı Anlatın'), findsOneWidget);
      expect(find.text('Yorumla'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('DreamInputScreen - boş metin ile yorumlama', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: DreamInputScreen(),
          ),
        ),
      );

      // Yorumla butonuna bas
      await tester.tap(find.text('Yorumla'));
      await tester.pump();

      // Hata mesajının görünür olduğunu kontrol et
      expect(find.text('Lütfen rüyanızı yazın'), findsOneWidget);
    });

    testWidgets('DreamInputScreen - metin girişi', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: DreamInputScreen(),
          ),
        ),
      );

      // TextField'a metin gir
      await tester.enterText(find.byType(TextField), 'Test rüyası');
      await tester.pump();

      // Metnin girildiğini kontrol et
      expect(find.text('Test rüyası'), findsOneWidget);
    });
  });

  group('PremiumScreen Widget Tests', () {
    testWidgets('PremiumScreen - temel görünüm', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: PremiumScreen(),
          ),
        ),
      );

      // Temel elementlerin görünür olduğunu kontrol et
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Premium Paketler'), findsOneWidget);
      expect(find.text('Premium Özellikler'), findsOneWidget);
    });

    testWidgets('PremiumScreen - paket kartları', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: PremiumScreen(),
          ),
        ),
      );

      // Paket kartlarının görünür olduğunu kontrol et
      expect(find.text('7 Rüya Paketi'), findsOneWidget);
      expect(find.text('14 Rüya Paketi'), findsOneWidget);
      expect(find.text('21 Rüya Paketi'), findsOneWidget);
      expect(find.text('28 Rüya Paketi'), findsOneWidget);
    });

    testWidgets('PremiumScreen - özellikler listesi', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AnimationService()),
            ChangeNotifierProvider(create: (context) => PaymentService()),
          ],
          child: const MaterialApp(
            home: PremiumScreen(),
          ),
        ),
      );

      // Özelliklerin görünür olduğunu kontrol et
      expect(find.text('Sınırsız Rüya Yorumu'), findsOneWidget);
      expect(find.text('Gelişmiş Paylaşım'), findsOneWidget);
      expect(find.text('Geçmiş Kayıtları'), findsOneWidget);
      expect(find.text('Öncelikli Destek'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Ana navigasyon - tab geçişleri', (WidgetTester tester) async {
      await tester.pumpWidget(const DreamsAIApp());

      // İlk tab aktif olmalı
      expect(find.text('Rüya Yorumla'), findsOneWidget);

      // İkinci tab'a geç
      await tester.tap(find.text('Geçmiş'));
      await tester.pump();

      // Geçmiş ekranının görünür olduğunu kontrol et
      expect(find.text('Geçmiş'), findsOneWidget);

      // Üçüncü tab'a geç
      await tester.tap(find.text('Profil'));
      await tester.pump();

      // Profil ekranının görünür olduğunu kontrol et
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Floating Action Button - Premium ekranına geçiş', (WidgetTester tester) async {
      await tester.pumpWidget(const DreamsAIApp());

      // FAB'a bas
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Premium ekranının açıldığını kontrol et
      expect(find.text('Premium'), findsOneWidget);
    });
  });
}
