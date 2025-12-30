import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core imports
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// Auth Features
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/two_factor_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

// Home Feature
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KomiutApp(),
    ),
  );
}

class KomiutApp extends ConsumerWidget {
  const KomiutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Komiut',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      initialRoute: '/',

      // Centralized Route Map
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/two-factor': (context) => const TwoFactorScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}