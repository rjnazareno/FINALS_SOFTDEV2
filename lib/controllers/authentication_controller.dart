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
      _showSnackbar(context, "Profile Image", "Successfully selected your profile image.", true);
    }
  }

  Future<void> pickImageFileFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
      _showSnackbar(context, "Profile Image", "Successfully captured your profile image.", true);
    }
  }

  // 🧾 New user (email+password)
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
    String gender,
    String status,
    String extra,
    String s,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
      );

      _showSnackbar(context, "Account Created", "You have successfully created an account.", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showSnackbar(context, "Account Creation Failed", "$e", false);
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
  
  Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  // Invalidate all user-related providers (refresh state)
  ref.invalidate(userProvider);

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
















  // 💾 Store user data in Firestore
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

  // 🔐 Login with email/password
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

  // 🔔 Snackbar
  void _showSnackbar(BuildContext context, String title, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text("$title\n$message"),
      backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 🔓 Google Sign-In (✅ fixed to show account chooser)
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // ✅ Force account chooser by signing out first
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _showSnackbar(context, "Google Sign-In", "Sign-in cancelled by user.", false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        _showSnackbar(context, "Google Sign-In Failed", "User info not found.", false);
        return;
      }

      final bool exists = await checkUserProfileExists(user.uid);

      if (exists) {
        _showSnackbar(context, "Welcome Back", "Logged in successfully.", true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        _showSnackbar(context, "New User", "Redirecting to complete registration.", true);
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
      _showSnackbar(context, "Google Sign-In Failed", e.toString(), false);
    }
  }

  // 🔍 Check if user profile exists in Firestore
  Future<bool> checkUserProfileExists(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists;
  }


  // 💾 Store profile for Google user
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
}
