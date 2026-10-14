import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Intentionally do not pretend Firebase is connected.
  }
  AppConfig.firebaseReady = firebaseReady;
  runApp(const ResQMitraApp());
}

class ResQMitraApp extends StatelessWidget {
  const ResQMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQMitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFE8F6FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF168DDB),
          primary: const Color(0xFF168DDB),
          secondary: const Color(0xFF078B43),
          surface: Colors.white,
          error: Colors.red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF102A56),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD2DCE5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD2DCE5)),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
