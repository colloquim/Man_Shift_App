// services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart'; // make sure this exists

class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;

  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late FirebaseAnalytics analytics;

  // Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      analytics = FirebaseAnalytics.instance;

      if (kDebugMode) print("Firebase initialized successfully.");
    } catch (e) {
      if (kDebugMode) print("Firebase initialization failed: $e");
    }
  }

  // Log events
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) print("Logged event: $name, $parameters");
    } catch (e) {
      if (kDebugMode) print("Failed to log event: $e");
    }
  }
}
