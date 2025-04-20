import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for user data
final userProvider = FutureProvider<DocumentSnapshot>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception("No user logged in");
  }
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();
  return userDoc;
});
