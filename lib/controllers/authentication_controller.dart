// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/home_screen.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  late Rx<User?> firebaseCurrentUser;

  late Rx<File?> pickedFile;
  File? get profileImage => pickedFile.value;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    pickedFile = Rx<File?>(null);
  }

  // Pick image from Gallery
  Future<void> pickImageFileFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedFile.value = File(image.path);
      _showSnackbar("Profile Image", "Successfully selected your profile image.");
    }
  }

  // Pick image from Camera
  Future<void> pickImageFileFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedFile.value = File(image.path);
      _showSnackbar("Profile Image", "Successfully captured your profile image.");
    }
  }

  // Create new user account
  Future<void> createNewUserAccount(
    String email,
    String password,
    String name,
    String age,
    String phoneNo,
    String city,
    String courseOrStrand,
    String lookingForInaPartner,
    String gender,
    String status, String s,
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
        courseOrStrand: courseOrStrand,
        lookingForInaPartner: lookingForInaPartner,
        gender: gender,
        imageUrl: imageUrl,
      );

      _showSnackbar("Account Created", "You have successfully created an account.", isSuccess: true);
      Get.offAll(() => const HomeScreen());
    } catch (error) {
      _showSnackbar("Account Creation Failed", "$error", isSuccess: false);
    }
  }

  // Upload image to Firebase Storage
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
    required String courseOrStrand,
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
      'courseOrStrand': courseOrStrand,
      'lookingForInaPartner': lookingForInaPartner,
      'gender': gender,
      'imageProfile': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Log in user securely
  Future<void> loginUser(String emailUser, String passwordUser) async {
    try {
      // Attempt FirebaseAuth sign-in
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailUser,
        password: passwordUser,
      );

      final userId = credential.user!.uid;

      // Check if user profile exists in Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        _showSnackbar("Login Failed", "User profile not found. Please register first.", isSuccess: false);
        return;
      }

      final userData = userDoc.data();
      if (userData == null || userData['email'] != emailUser) {
        await _auth.signOut();
        _showSnackbar("Login Failed", "Account data mismatch. Contact support.", isSuccess: false);
        return;
      }

      // All good — login
      _showSnackbar("Logged In Successfully", "Welcome back!", isSuccess: true);
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Incorrect password.";
      }
      _showSnackbar("Login Failed", errorMsg, isSuccess: false);
    } catch (error) {
      _showSnackbar("Login Failed", "Unexpected error: $error", isSuccess: false);
    }
  }

  // Helper to show snackbars
  void _showSnackbar(String title, String message, {bool isSuccess = true}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess ? Colors.green.withOpacity(0.85) : Colors.redAccent.withOpacity(0.85),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  checkifUserisLoggedIn(User? currentUser)  {
    if (currentUser == null) 
    {
      Get.to(LoginScreen());
    } 
    else 
    {
      Get.to(HomeScreen());
    }
  }

  @override
  void onReady() {
    super.onReady();

    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    ever(firebaseCurrentUser, checkifUserisLoggedIn);
  }

  signInWithGoogle() {}

  checkUserProfileExists() {}

  storeGoogleUserProfile(String trim, String trim2, String trim3, String trim4, String trim5, String trim6, String trim7, String trim8) {}
}
