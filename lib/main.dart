import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/login_screen.dart';
import 'screens/set_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/route_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/post_route_screen.dart';
import 'screens/edit_route_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setLanguageCode('en');

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const RideApp());
}

class RideApp extends StatefulWidget {
  const RideApp({super.key});

  @override
  State<RideApp> createState() => _RideAppState();
}

class _RideAppState extends State<RideApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/login': (context) => const LoginScreen(),
        '/set-password': (context) => const SetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/route-detail': (context) => const RouteDetailScreen(),
        '/profile': (context) => ProfileScreen(
              isDarkMode: _isDarkMode,
              onDarkModeToggle: (val) => setState(() => _isDarkMode = val),
            ),
        '/post-route': (context) => const PostRouteScreen(),
        '/edit-route': (context) => const EditRouteScreen(),
      },
    );
  }
}