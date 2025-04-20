// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/home_screen.dart';

// Create a Riverpod provider for AuthenticationController
final authControllerProvider = ChangeNotifierProvider<AuthenticationController>((ref) {
  return AuthenticationController(ref);
});

class AuthenticationController extends ChangeNotifier {
  final Ref ref;
  AuthenticationController(this.ref);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _profileImage;
  File? get profileImage => _profileImage;

  User? get currentUser => _auth.currentUser;

  // Pick an image from the gallery
  Future<void> pickImageFileFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
      _showSnackbar(context, "Profile Image", "Successfully selected your profile image.", true);
    }
  }

  // Pick an image from the camera
  Future<void> pickImageFileFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
      _showSnackbar(context, "Profile Image", "Successfully captured your profile image.", true);
    }
  }

  // Create a new user account
  Future<void> createNewUserAccount(
    BuildContext context,
    String email,
    String password,
    String name,
    String age,
    String phoneNo,
    String city,
    String courseOrStrand,
    String lookingForInaPartner,
    String selectedGender,
    String status,
    String extra, String s,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String imageUrl = "";

      if (_profileImage != null) {
        imageUrl = await _uploadImageToStorage(_profileImage!);
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
        gender: selectedGender,
        imageUrl: imageUrl,
      );

      _showSnackbar(context, "Account Created", "You have successfully created an account.", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showSnackbar(context, "Account Creation Failed", "$e", false);
    }
  }

  // Upload the image to Firebase Storage
  Future<String> _uploadImageToStorage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child("profile_images/$fileName.jpg");
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  // Save the user to Firestore
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
    await _firestore.collection('users').doc(uid).set({
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

  // Log in with email and password
  Future<void> loginUser(BuildContext context, String emailUser, String passwordUser) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: emailUser, password: passwordUser);
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        _showSnackbar(context, "Login Failed", "User profile not found. Please register first.", false);
        return;
      }

      final userData = userDoc.data();
      if (userData == null || userData['email'] != emailUser) {
        await _auth.signOut();
        _showSnackbar(context, "Login Failed", "Account data mismatch. Contact support.", false);
        return;
      }

      _showSnackbar(context, "Logged In Successfully", "Welcome back!", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Incorrect password.";
      }
      _showSnackbar(context, "Login Failed", errorMsg, false);
    } catch (error) {
      _showSnackbar(context, "Login Failed", "Unexpected error: $error", false);
    }
  }

  // Show snackbar messages
  void _showSnackbar(BuildContext context, String title, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text("$title\n$message"),
      backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Check if user is logged in
  void checkIfUserIsLoggedIn(BuildContext context) {
    if (_auth.currentUser == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  // Placeholder methods for Google sign-in, can be filled later
  void signInWithGoogle() {}
  void checkUserProfileExists() {}
  void storeGoogleUserProfile(String trim, String trim2, String trim3, String trim4, String trim5, String trim6, String trim7) {}
}
