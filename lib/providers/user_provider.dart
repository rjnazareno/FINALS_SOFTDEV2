import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Riverpod [FutureProvider] that fetches the current user's Firestore document.
final userProvider = FutureProvider.autoDispose<DocumentSnapshot<Map<String, dynamic>>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message: "No user is currently logged in.",
    );
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!userDoc.exists || userDoc.data() == null) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'User profile not found in Firestore.',
    );
  }

  return userDoc;
});
