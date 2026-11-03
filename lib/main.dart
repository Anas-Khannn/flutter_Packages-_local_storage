import 'package:flutter/material.dart';

import 'screens/secure_note_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SecureStorageApp());
}

class SecureStorageApp extends StatelessWidget {
  const SecureStorageApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Secure Storage Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5EC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF527244),
        primary: const Color(0xFF293B2B),
        surface: const Color(0xFFF5F5EC),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5EC),
        foregroundColor: Color(0xFF202B2A),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF202B2A),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFDDF988),
          foregroundColor: const Color(0xFF202B2A),
          minimumSize: const Size(0, 56),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF36433A),
          minimumSize: const Size(0, 56),
          side: const BorderSide(color: Color(0xFFCCD1C3)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF202B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    home: const SecureNoteScreen(),
  );
}
