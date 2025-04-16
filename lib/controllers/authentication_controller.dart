// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ua_dating_app/home_screen.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  late Rx<File?> pickedFile;
  File? get profileImage => pickedFile.value;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  get currentUser => null;

  @override
  void onInit() {
    super.onInit();
    pickedFile = Rx<File?>(null);
  }

  // Pick from Gallery
  Future<void> pickImageFileFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedFile.value = File(image.path);
      _showSnackbar("Profile Image", "Successfully selected your profile image.");
    }
  }

  // Pick from Camera
  Future<void> pickImageFileFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedFile.value = File(image.path);
      _showSnackbar("Profile Image", "Successfully captured your profile image.");
    }
  }

  // Create new user (email/password users)
  Future<void> createNewUserAccount(
    String email,
    String password,
    String name,
    String age,
    String phoneNo,
    String city,
    String country,
    String lookingForInaPartner,
    String gender,
    String s,
  ) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String imageUrl = "";
      if (profileImage != null) {
        imageUrl = await uploadImageToStorage(profileImage!);
      }

      await _saveUserToFirestore(
        uid: credential.user!.uid,
        email: email,
        name: name,
        age: age,
        phoneNo: phoneNo,
        city: city,
        country: country,
        lookingForInaPartner: lookingForInaPartner,
        gender: gender,
        imageUrl: imageUrl,
      );

      _showSnackbar("Account Created", "You have successfully created an account.", isSuccess: true);
    } catch (error) {
      _showSnackbar("Account Creation Failed", "Error: $error", isSuccess: false);
    }
  }

  // Google users complete profile (no need to create Firebase account again)
  Future<void> storeGoogleUserProfile(
    String name,
    String age,
    String phoneNo,
    String city,
    String country,
    String lookingForInaPartner,
    String gender,
  ) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        _showSnackbar("Error", "No Google user found.", isSuccess: false);
        return;
      }

      String imageUrl = "";
      if (profileImage != null) {
        imageUrl = await uploadImageToStorage(profileImage!);
      }

      await _saveUserToFirestore(
        uid: user.uid,
        email: user.email ?? "",
        name: name,
        age: age,
        phoneNo: phoneNo,
        city: city,
        country: country,
        lookingForInaPartner: lookingForInaPartner,
        gender: gender,
        imageUrl: imageUrl,
      );

      _showSnackbar("Profile Saved", "Google user profile completed.", isSuccess: true);
    } catch (e) {
      _showSnackbar("Error", "Failed to save Google profile: $e", isSuccess: false);
    }
  }

  // Upload to Firebase Storage
  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child("profile_images/$fileName.jpg");
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String name,
    required String age,
    required String phoneNo,
    required String city,
    required String country,
    required String lookingForInaPartner,
    required String gender,
    required String imageUrl,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'phoneNo': phoneNo,
      'city': city,
      'country': country,
      'lookingForInaPartner': lookingForInaPartner,
      'gender': gender,
      'imageProfile': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Show snackbars
  void _showSnackbar(String title, String message, {bool isSuccess = true}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // Login user (email/password)
  Future<void> loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailUser,
        password: passwordUser,
      );

      Get.snackbar(
        "Logged In Successfully",
        "Welcome back!",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      Get.to(() => const HomeScreen());
    } catch (errorMsg) {
      _showSnackbar("Login Failed", "Error: $errorMsg", isSuccess: false);
    } finally {
      // Any cleanup or final actions can go here if needed
    }
  }

  signInWithGoogle() {}

  checkUserProfileExists() {}
}
