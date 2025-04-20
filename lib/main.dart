import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'authentication/login_screen.dart';

// Entry point for the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(  // Wrap the app in ProviderScope
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UA Dating App',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 253, 253, 253),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
