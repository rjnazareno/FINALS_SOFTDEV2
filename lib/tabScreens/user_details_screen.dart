// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
  }

  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Color.fromARGB(255, 51, 51, 51),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black87,
                height: 1.4, // better line height for readability
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logoutUser,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: data['imageProfile'] != null &&
                          data['imageProfile'].toString().isNotEmpty
                      ? Image.network(
                          data['imageProfile'],
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          width: 180,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Info",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 51, 51, 51),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1.5, color: Colors.black26),
                const SizedBox(height: 16),

                // Info card container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo("Name", data['name'] ?? "N/A"),
                      _buildUserInfo("Age", data['age'] ?? "N/A"),
                      _buildUserInfo("Phone", data['phoneNo'] ?? "N/A"),
                      _buildUserInfo("City", data['city'] ?? "N/A"),
                      _buildUserInfo("Gender", data['courseOrStrand'] ?? "N/A"),
                      _buildUserInfo("Course/Strand", data['lookingForInaPartner'] ?? "N/A"),
                      _buildUserInfo("Looking For", data['gender'] ?? "N/A"),
                      _buildUserInfo("Email", data['email'] ?? "N/A"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
