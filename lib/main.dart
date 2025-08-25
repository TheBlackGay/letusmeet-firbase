import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/screens/authentication_screen.dart'; // Import authentication screen
import 'package:myapp/screens/home_page.dart'; // Import HomePage
import 'package:myapp/screens/create_activity_screen.dart'; // Import create activity screen

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
 return const HomePage(); // Use HomePage instead of MyHomePage
                } else {
                  return const LoginScreen();
                }
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/create_activity': (context) => const CreateActivityScreen(),
        '/authentication': (context) => const AuthenticationScreen(), // Add authentication route
      },
    );
  }
}
