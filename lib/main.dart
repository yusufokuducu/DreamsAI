import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status bar'ı tamamen siyah yap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const DreamsAIApp());
}

class DreamsAIApp extends StatelessWidget {
  const DreamsAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreams AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF000000),
          background: Color(0xFF000000),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF000000),
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Color(0xFF555555),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        dividerColor: Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
