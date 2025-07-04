import 'package:flutter/material.dart';
import 'screens/language_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_verification_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Calley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LanguageSelectionScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: args['email'],
              username: args['username'],
              password: args['password'],
            ),
          );
        }
        return null;
      },
    );
  }
}
