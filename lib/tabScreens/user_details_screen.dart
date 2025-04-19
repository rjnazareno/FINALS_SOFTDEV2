import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Logout function
  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen()); // Navigate to LoginScreen and remove all previous routes
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        // ignore: deprecated_member_use
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logoutUser,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'User Profile Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
