import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'firebase_options.dart';

/// Application entry: initializes Firebase, env, and runs Fit Diary.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Web loads .env from assets (see pubspec.yaml); mobile/desktop can read project root.
  await dotenv.load(fileName: '.env');
  runApp(buildAppWithProviders());
}
