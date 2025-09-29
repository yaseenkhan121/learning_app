import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learning_app/screens/home_screen.dart';
import 'package:learning_app/screens/login_screen.dart';
import 'package:learning_app/screens/signup_screen.dart';
import 'package:learning_app/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Load environment variables (YouTube API key, etc.)
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ added key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat', // remember to include in pubspec.yaml
        scaffoldBackgroundColor: const Color(0xFFE8F0F7), // Light blue background
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) =>  SignUpScreen(),
        '/home': (context) =>  HomeScreen(),
      },
    );
  }
}
