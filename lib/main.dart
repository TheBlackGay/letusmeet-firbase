import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/modern_login_screen_cn.dart';
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/screens/modern_registration_screen.dart';
import 'package:myapp/screens/modern_create_activity_screen.dart';
import 'package:myapp/screens/authentication_screen.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:myapp/screens/create_activity_screen.dart';
import 'package:myapp/screens/activity_detail_screen.dart';
import 'package:myapp/screens/animated_activity_detail_screen.dart';
import 'package:myapp/services/mock_auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/widgets/dev_mode_banner_cn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not in development mode
  if (!AppConfig.isDevelopmentMode) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      AppConfig.log('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
      // Continue anyway for development
    }
  } else {
    AppConfig.log('Development mode: Skipping Firebase initialization');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QingYue Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Modern purple
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          // Development mode: Skip authentication
          if (AppConfig.skipAuthentication) {
            AppConfig.log('Development mode: Skipping authentication, going to HomePage');
            return HomePage();
          }

          // Production mode: Check authentication
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData || MockAuthService.isLoggedIn) {
                return HomePage();
              } else {
                return ModernLoginScreen();
              }
            },
          );
        },
        '/login': (context) => ModernLoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/create_activity': (context) => CreateActivityScreen(),
        '/authentication': (context) => AuthenticationScreen(),
        '/activity_detail': (context) {
          final activityId = ModalRoute.of(context)!.settings.arguments as String;
          return AnimatedActivityDetailScreen(activityId: activityId);
        },
      },
    );
  }
}
