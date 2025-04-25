// ignore_for_file: use_build_context_synchronously, deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ua_dating_app/providers/user_provider.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/tabScreens/settings_screen.dart';

class UserDetailsScreen extends ConsumerWidget {
  const UserDetailsScreen({super.key});

  // Build user info
  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the back arrow
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu), // 3-bar menu icon
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: userAsyncValue.when(
        data: (userDoc) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo("Name", userData["name"] ?? "N/A"),
                _buildUserInfo("Email", userData["email"] ?? "N/A"),
                _buildUserInfo("Age", userData["age"] ?? "N/A"),
                _buildUserInfo("City", userData["city"] ?? "N/A"),
                _buildUserInfo("Gender", userData["gender"] ?? "N/A"),
                _buildUserInfo("Course/Strand", userData["courseOrStrand"] ?? "N/A"),
                _buildUserInfo("Looking For", userData["lookingForInaPartner"] ?? "N/A"),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
