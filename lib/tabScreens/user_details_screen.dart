// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ua_dating_app/providers/user_provider.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final picker = ImagePicker();
  bool isEditing = false;
  final Map<String, TextEditingController> _controllers = {};

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
    };
    await FirebaseFirestore.instance.collection("users").doc(userId).update(updatedData);
    setState(() => isEditing = false);
  }

  Future<void> _changeImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
      await storageRef.putFile(File(pickedFile.path));
      final imageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection("users").doc(userId).update({'imageProfile': imageUrl});
      ref.invalidate(userProvider);
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String key,
    bool editable = true,
  }) {
    final boldColor = const Color.fromARGB(255, 68, 68, 68);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: isEditing && editable
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(icon, color: boldColor),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controllers[key],
                    style: TextStyle(color: boldColor), // match display color
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: boldColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.toUpperCase(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_controllers[key]?.text ?? '',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: boldColor)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: userAsyncValue.when(
        data: (userDoc) {
          if (!userDoc.exists) return const Center(child: Text("User data not found."));
          final data = userDoc.data() as Map<String, dynamic>;

          for (var field in [
            'name', 'age', 'phoneNo', 'city', 'gender',
            'courseOrStrand', 'lookingForInaPartner', 'email'
          ]) {
            _controllers[field] ??= TextEditingController(text: data[field] ?? '');
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: isEditing ? _changeImage : null,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          SizedBox(
                            height: 480,
                            width: double.infinity,
                            child: data['imageProfile'] != null &&
                                    data['imageProfile'].toString().isNotEmpty
                                ? Image.network(data['imageProfile'], fit: BoxFit.cover)
                                : Container(color: Colors.grey[300]),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // ignore: deprecated_member_use
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${data['name']}, ${data['age']}',
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(data['gender'] ?? '',
                                    style: const TextStyle(fontSize: 18, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info Containers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        children: [
                           _infoTile(icon: Icons.email, title: 'Email', key: 'email', editable: false),
                          _infoTile(icon: Icons.location_city, title: 'City', key: 'city'),
                          _infoTile(icon: Icons.school, title: 'Course / Strand', key: 'courseOrStrand'),
                          _infoTile(icon: Icons.favorite, title: 'Looking For in a Partner', key: 'lookingForInaPartner'),
                          _infoTile(icon: Icons.phone, title: 'Phone Number', key: 'phoneNo'),
                          if (isEditing)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: ElevatedButton.icon(
                                onPressed: _saveToFirestore,
                                icon: const Icon(Icons.save),
                                label: const Text("Save"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Edit Button
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () => setState(() => isEditing = !isEditing),
                  child: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
