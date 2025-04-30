// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/providers/user_provider.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final picker = ImagePicker();

  Future<void> _saveToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final updatedData = {
      'name': _controllers['name']!.text.trim(),
      'age': _controllers['age']!.text.trim(),
      'city': _controllers['city']!.text.trim(),
      'phoneNo': _controllers['phoneNo']!.text.trim(),
      'gender': _controllers['gender']!.text.trim(),
      'courseOrStrand': _controllers['courseOrStrand']!.text.trim(),
      'lookingForInaPartner': _controllers['lookingForInaPartner']!.text.trim(),
      'email': _controllers['email']!.text.trim(),
    };
    await FirebaseFirestore.instance.collection("users").doc(userId).update(updatedData);
  }

  Future<void> _changeImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(File(pickedFile.path));
      final imageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection("users").doc(userId).update({'imageProfile': imageUrl});
      ref.invalidate(userProvider); // Refresh user data
    }
  }

  Widget _buildEditableField(String label, String key, {int maxLines = 1, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[key],
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          color: readOnly ? Colors.grey[600] : const Color.fromARGB(255, 68, 68, 68),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          fillColor: readOnly ? Colors.grey.shade100 : null,
          filled: readOnly,
          suffixIcon: !readOnly ? const Icon(Icons.edit, color: Color.fromARGB(255, 68, 68, 68)) : null,
        ),
        onChanged: (value) async {
          if (!readOnly) await _saveToFirestore();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("About Me", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
  icon: const Icon(Icons.logout, color: Colors.redAccent),
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await FirebaseAuth.instance.signOut();

      // Close loading spinner
      Navigator.of(context, rootNavigator: true).pop();

      // Navigate to LoginScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  },
),
        ],
      ),
      body: userAsyncValue.when(
        data: (userDoc) {
          if (!userDoc.exists) return const Center(child: Text("User data not found."));
          final data = userDoc.data() as Map<String, dynamic>;

          for (var field in ['name', 'age', 'phoneNo', 'city', 'gender', 'courseOrStrand', 'lookingForInaPartner', 'email']) {
            _controllers[field] ??= TextEditingController(text: data[field] ?? '');
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _changeImage,
                    child: Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: data['imageProfile'] != null && data['imageProfile'].toString().isNotEmpty
                                ? Image.network(
                                    data['imageProfile'],
                                    height: 500,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 500,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 100, color: Colors.white),
                                  ),
                          ),

                          // Gradient overlay at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                          // Image Picker Icon Centered
                          const Positioned(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera, color: Colors.white, size: 30),
                                SizedBox(height: 4),
                                Text(
                                  'Change Photo',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          // Bottom-left: Name, Age, Gender
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['name'] ?? 'Name'}, ${data['age'] ?? ''}",
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${data['gender'] ?? 'Gender'}",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // Bottom-right: City + Looking For
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text("${data['city'] ?? 'City'}", style: const TextStyle(fontSize: 16, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Looking for: ${data['lookingForInaPartner'] ?? 'N/A'}",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Editable Fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildEditableField("Email", 'email', readOnly: true),
                        _buildEditableField("City", 'city'),
                        _buildEditableField("Phone Number", 'phoneNo'),
                        _buildEditableField("Course/Strand", 'courseOrStrand'),
                        _buildEditableField("Looking For", 'lookingForInaPartner'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
