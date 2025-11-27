// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase correctly
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MANSHIFTApp());
}

class MANSHIFTApp extends StatelessWidget {
  const MANSHIFTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MANSHIFT AI Mentor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00A8A8),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF00A8A8),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
