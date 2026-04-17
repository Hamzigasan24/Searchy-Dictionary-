import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

bool firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    print("FIREBASE INITIALIZATION ERROR: $e");
    firebaseReady = false;
  }
  runApp(const SearchyDictApp());
}

class SearchyDictApp extends StatelessWidget {
  const SearchyDictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'SearcHub',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
