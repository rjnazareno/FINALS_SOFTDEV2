// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
      'bio': _controllers['bio']!.text.trim(),
      'interests': _controllers['interests']!.text.trim(),
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
                    style: TextStyle(color: boldColor),
                    maxLines: key == 'bio' ? 5 : 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                        Text(
  _controllers[key]?.text ?? '',
  style: TextStyle(
    fontSize: 18,
    fontWeight: key == 'bio' ? FontWeight.bold : FontWeight.w500,
    color: boldColor,
  ),
),

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 89, 54, 244)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 48, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    _controllers['name']?.text ?? 'Your Profile',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'UA Dating App',
                  applicationVersion: '1.0.0',
                  children: const [Text('This is a dating app for UA students.')],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: userAsyncValue.when(
        data: (userDoc) {
          if (!userDoc.exists) return const Center(child: Text("User data not found."));
          final data = userDoc.data() as Map<String, dynamic>;

          for (var field in [
            'name', 'age', 'phoneNo', 'city', 'gender',
            'courseOrStrand', 'lookingForInaPartner', 'bio', 'interests'
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
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 480,
                            width: double.infinity,
                            child: data['imageProfile'] != null &&
                                    data['imageProfile'].toString().isNotEmpty
                                ? Image.network(data['imageProfile'], fit: BoxFit.cover)
                                : Container(color: Colors.grey[300]),
                          ),
                          if (isEditing)
                            Container(
                              height: 480,
                              color: Colors.black26,
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: _changeImage,
                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                  label: const Text("Change Image", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
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
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        children: [
                          _infoTile(icon: Icons.person, title: 'Bio', key: 'bio'),
                           _infoTile(icon: Icons.school, title: 'Course / Strand', key: 'courseOrStrand'),
                          _infoTile(icon: Icons.interests, title: 'Interests (use comma)', key: 'interests'),
                         _infoTile(icon: Icons.favorite, title: 'Looking For in a Partner (use comma)', key: 'lookingForInaPartner'),
                          _infoTile(icon: Icons.location_city, title: 'City', key: 'city'),
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
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 230, 207, 3),
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
