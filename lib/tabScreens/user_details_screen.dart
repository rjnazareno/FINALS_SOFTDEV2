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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (data['imageProfile'] != null && data['imageProfile'].toString().isNotEmpty)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(data['imageProfile']),
                  )
                else
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                const SizedBox(height: 20),

                _buildUserInfo("Name", data['name'] ?? "N/A"),
                _buildUserInfo("Age", data['age'] ?? "N/A"),
                _buildUserInfo("Phone", data['phoneNo'] ?? "N/A"),
                _buildUserInfo("City", data['city'] ?? "N/A"),
                _buildUserInfo("Gender", data['gender'] ?? "N/A"),
                _buildUserInfo("Course/Strand", data['courseOrStrand'] ?? "N/A"),
                _buildUserInfo("Looking For", data['lookingForInaPartner'] ?? "N/A"),
                _buildUserInfo("Email", data['email'] ?? "N/A"),
              ],
            ),
          );
        },
      ),
    );
  }
}
