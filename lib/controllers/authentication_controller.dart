// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/authentication/registration_screen.dart';
import 'package:ua_dating_app/home_screen.dart';
import 'package:ua_dating_app/providers/user_provider.dart';

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

  // 📸 Image pickers
  Future<void> pickImageFileFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
      if (!context.mounted) return;
      _showSnackbar(context, "Profile Image", "Successfully selected your profile image.", true);
    }
  }

  Future<void> pickImageFileFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
      if (!context.mounted) return;
      _showSnackbar(context, "Profile Image", "Successfully captured your profile image.", true);
    }
  }

Future<bool> createNewUserAccount(
  BuildContext context,
  String email,
  String password,
  String name,
  String age,
  String phoneNo,
  String city,
  String courseOrStrand,
  String lookingForInaPartner,
  String gender,
  String imagePath,
  String bio,
  String interests,
) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String imageUrl = "";
    if (_profileImage != null) {
      imageUrl = await uploadImageToStorage(_profileImage!);
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
      bio: bio,
      interests: interests,
    );

    if (!context.mounted) return false;
    _showSnackbar(context, "Account Created", "You have successfully registered.", true);
    return true;
  } on FirebaseAuthException catch (e) {
    String errorMsg = "Account creation failed.";
    if (e.code == 'email-already-in-use') {
      errorMsg = "That email is already registered.";
    } else if (e.code == 'invalid-email') {
      errorMsg = "The email address is invalid.";
    } else if (e.code == 'weak-password') {
      errorMsg = "Your password is too weak.";
    }

    if (!context.mounted) return false;
    _showSnackbar(context, "Registration Failed", errorMsg, false);
    await _auth.signOut();
    return false;
  } catch (e) {
    if (!context.mounted) return false;
    _showSnackbar(context, "Registration Failed", "Unexpected error: $e", false);
    await _auth.signOut();
    return false;
  }
}



  // 🔄 Upload image to Firebase Storage
  Future<String> uploadImageToStorage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child("profile_images/$fileName.jpg");
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  // 💾 Save user data to Firestore
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
    required String bio,
    required String interests,
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
      'bio': bio,
      'interests': interests,
      'imageProfile': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔐 Login
  Future<void> loginUser(BuildContext context, String emailUser, String passwordUser) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: emailUser, password: passwordUser);
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        if (!context.mounted) return;
        _showSnackbar(context, "Login Failed", "User profile not found. Please register first.", false);
        return;
      }

      final userData = userDoc.data();
      if (userData == null || userData['email'] != emailUser) {
        await _auth.signOut();
        if (!context.mounted) return;
        _showSnackbar(context, "Login Failed", "Account data mismatch. Contact support.", false);
        return;
      }

      if (!context.mounted) return;
      _showSnackbar(context, "Login Success", "Welcome back!", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Incorrect password.";
      }
      if (!context.mounted) return;
      _showSnackbar(context, "Login Failed", errorMsg, false);
    } catch (error) {
      if (!context.mounted) return;
      _showSnackbar(context, "Login Failed", "Unexpected error: $error", false);
    }
  }

  // 🔓 Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // force chooser
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (!context.mounted) return;
        _showSnackbar(context, "Google Sign-In", "Cancelled by user.", false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        if (!context.mounted) return;
        _showSnackbar(context, "Google Sign-In Failed", "User not found.", false);
        return;
      }

      final bool exists = await checkUserProfileExists(user.uid);

      if (!context.mounted) return;

      if (exists) {
        _showSnackbar(context, "Welcome Back", "Logged in successfully.", true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        _showSnackbar(context, "New User", "Please complete your profile information.", true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationScreen(
              email: user.email ?? "",
              isGoogleUser: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, "Google Sign-In Failed", e.toString(), false);
    }
  }

  // ✅ Google user: store extra profile info
  Future<void> storeGoogleUserProfile({
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
    required String bio,
    required String interests,
  }) async {
    await _saveUserToFirestore(
      uid: uid,
      email: email,
      name: name,
      age: age,
      phoneNo: phoneNo,
      city: city,
      courseOrStrand: courseOrStrand,
      lookingForInaPartner: lookingForInaPartner,
      gender: gender,
      imageUrl: imageUrl,
      bio: bio,
      interests: interests,
    );
  }

  // Check Firestore for existing profile
  Future<bool> checkUserProfileExists(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists;
  }

  // 🚪 Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    ref.invalidate(userProvider);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Snackbar
  void _showSnackbar(BuildContext context, String title, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text("$title\n$message"),
      backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
