// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ua_dating_app/models/person.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, List<Person>>((ref) {
  return ProfileController();
});

class ProfileController extends StateNotifier<List<Person>> {
  ProfileController() : super([]) {
    _listenToProfiles();
  }

  final String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  void _listenToProfiles() {
    if (currentUserID.isEmpty) {
      state = [];
      return;
    }

    FirebaseFirestore.instance
        .collection("users")
        .where("uid", isNotEqualTo: currentUserID)
        .snapshots()
        .listen((querySnapshot) {
      final profilesList = querySnapshot.docs
          .map((doc) => Person.fromDataSnapshot(doc))
          .toList();
      state = profilesList;
    });
  }

  /// Like someone (only if not already liked)
  Future<void> likeSentAndLikeReceived(String toUserID, String senderName) async {
    if (currentUserID.isEmpty) return;

    final currentUserRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef = FirebaseFirestore.instance.collection("users").doc(toUserID);

    final doc = await currentUserRef.collection("likeSent").doc(toUserID).get();

    if (!doc.exists) {
      await toUserRef.collection("likeReceived").doc(currentUserID).set({
        "name": senderName,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection("likeSent").doc(toUserID).set({
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  /// Dislike/remove a previously liked user
  Future<void> removeLike(String toUserID) async {
    if (currentUserID.isEmpty) return;

    final currentUserRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef = FirebaseFirestore.instance.collection("users").doc(toUserID);

    await toUserRef.collection("likeReceived").doc(currentUserID).delete();
    await currentUserRef.collection("likeSent").doc(toUserID).delete();
  }

  /// Check if user is already liked
  Future<bool> isAlreadyLiked(String toUserID) async {
    if (currentUserID.isEmpty) return false;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("likeSent")
        .doc(toUserID)
        .get();

    return doc.exists;
  }
}
