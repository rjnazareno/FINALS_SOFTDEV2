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

  // Ensure current user is properly fetched and handled
  final String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  void _listenToProfiles() {
    if (currentUserID.isEmpty) {
      // If the user is not authenticated, don't fetch profiles
      state = [];
      return;
    }

    // Listen to the profiles of other users
    FirebaseFirestore.instance
        .collection("users")
        .where("uid", isNotEqualTo: currentUserID)
        .snapshots()
        .listen((querySnapshot) {
      final profilesList =
          querySnapshot.docs.map((doc) => Person.fromDataSnapshot(doc)).toList();
      state = profilesList; // Update the state with new profiles
    });
  }

  Future<void> likeSentAndLikeReceived(
      String toUserID, String senderName) async {
    if (currentUserID.isEmpty) return; // If the user is not authenticated, do nothing

    final currentUserRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef = FirebaseFirestore.instance.collection("users").doc(toUserID);

    // Check if the "likeReceived" document exists for the target user
    final doc =
        await toUserRef.collection("likeReceived").doc(currentUserID).get();

    if (doc.exists) {
      // Unlike: remove both "likeReceived" and "likeSent"
      await toUserRef.collection("likeReceived").doc(currentUserID).delete();
      await currentUserRef.collection("likeSent").doc(toUserID).delete();
    } else {
      // Like: add both "likeReceived" and "likeSent"
      await toUserRef.collection("likeReceived").doc(currentUserID).set({
        "name": senderName,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection("likeSent").doc(toUserID).set({
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }
}
