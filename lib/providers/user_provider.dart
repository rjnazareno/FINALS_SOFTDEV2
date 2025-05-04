import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Riverpod [FutureProvider] that fetches the currently logged-in user's document
final userProvider = FutureProvider.autoDispose<DocumentSnapshot<Map<String, dynamic>>>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message: "No user is currently logged in.",
    );
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!userDoc.exists) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'User document does not exist.',
    );
  }

  return userDoc;
});
