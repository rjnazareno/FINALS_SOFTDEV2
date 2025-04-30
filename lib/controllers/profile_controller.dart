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
    _init();
  }

  final String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  Set<String> dislikedIds = {};
  Set<String> likedIds = {};
  List<Person> _allProfiles = [];
  List<Person> temporarilyDislikedProfiles = [];

  void _init() {
    if (currentUserID.isEmpty) {
      state = [];
      return;
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("disliked")
        .snapshots()
        .listen((snapshot) {
      dislikedIds = snapshot.docs.map((doc) => doc.id).toSet();
      _filterProfiles();
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("likeSent")
        .snapshots()
        .listen((snapshot) {
      likedIds = snapshot.docs.map((doc) => doc.id).toSet();
      _filterProfiles();
    });

    FirebaseFirestore.instance
        .collection("users")
        .where("uid", isNotEqualTo: currentUserID)
        .snapshots()
        .listen((querySnapshot) {
      _allProfiles = querySnapshot.docs
          .map((doc) => Person.fromDataSnapshot(doc))
          .toList();
      _filterProfiles();
    });
  }

  // Check if a match is ongoing between the current user and the given user
  Future<bool> isMatchOngoing(String userId) async {
    final currentUserId = currentUserID;

    // Check if the current user has matched with this user
    final match1 = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("matches")
        .doc(userId)
        .get();

    // Check if the other user has matched with the current user
    final match2 = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("matches")
        .doc(currentUserId)
        .get();

    return match1.exists || match2.exists; // Return true if a match exists
  }

  void _filterProfiles() async {
    final filtered = await Future.wait(_allProfiles.map((person) async {
      final uid = person.uid;
      if (uid != null &&
          !dislikedIds.contains(uid) &&
          !likedIds.contains(uid) &&
          !await isMatchOngoing(uid)) {
        return person; // Only include the profile if it's not matched or disliked/liked
      }
      return null; // Exclude the profile if matched, disliked, or liked
    }));

    state = filtered.whereType<Person>().toList(); // Filter out null values (excluded profiles)
  }

  Future<void> likeSentAndLikeReceived(String toUserID, String senderName) async {
    if (currentUserID.isEmpty) return;

    final currentUserRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef =
        FirebaseFirestore.instance.collection("users").doc(toUserID);

    final alreadyLiked = await isAlreadyLiked(toUserID);

    if (!alreadyLiked) {
      await toUserRef.collection("likeReceived").doc(currentUserID).set({
        "name": senderName,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection("likeSent").doc(toUserID).set({
        "timestamp": FieldValue.serverTimestamp(),
      });

      final receivedLikeDoc = await currentUserRef
          .collection("likeReceived")
          .doc(toUserID)
          .get();

      if (receivedLikeDoc.exists) {
        await currentUserRef.collection("matches").doc(toUserID).set({
          "timestamp": FieldValue.serverTimestamp(),
        });
        await toUserRef.collection("matches").doc(currentUserID).set({
          "timestamp": FieldValue.serverTimestamp(),
        });

        // 💥 Remove likes from both sides
        await removeLikesBetween(currentUserID, toUserID);
      }
    }

    _removeProfileLocally(toUserID);
  }

  Future<void> dislikeUser(String toUserID) async {
    if (currentUserID.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("disliked")
        .doc(toUserID)
        .set({
      "timestamp": FieldValue.serverTimestamp(),
    });

    final profile = _allProfiles.firstWhere((p) => p.uid == toUserID, orElse: () => Person(uid: null));
    temporarilyDislikedProfiles.add(profile);

    _removeProfileLocally(toUserID);
  }

  Future<void> restoreLastDislikedProfile() async {
    if (temporarilyDislikedProfiles.isEmpty || currentUserID.isEmpty) return;

    final lastDisliked = temporarilyDislikedProfiles.removeLast();
    final restoredUid = lastDisliked.uid;

    if (restoredUid == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("disliked")
        .doc(restoredUid)
        .delete();

    _addProfileBack(lastDisliked);
  }

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

  Future<List<Person>> getMatchedUsers() async {
    if (currentUserID.isEmpty) return [];

    final matchesSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("matches")
        .get();

    final matchedUserIDs = matchesSnapshot.docs.map((doc) => doc.id).toList();

    if (matchedUserIDs.isEmpty) return [];

    final matchedProfilesSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("uid", whereIn: matchedUserIDs)
        .get();

    return matchedProfilesSnapshot.docs
        .map((doc) => Person.fromDataSnapshot(doc))
        .toList();
  }

  void _removeProfileLocally(String uid) {
    state = state.where((profile) => profile.uid != uid).toList();
  }

  void _addProfileBack(Person profile) {
    state = [...state, profile];
  }

  Future<void> removeLikesBetween(String userA, String userB) async {
    final batch = FirebaseFirestore.instance.batch();

    final userADoc = FirebaseFirestore.instance.collection("users").doc(userA);
    final userBDoc = FirebaseFirestore.instance.collection("users").doc(userB);

    batch.delete(userADoc.collection("likeSent").doc(userB));
    batch.delete(userADoc.collection("likeReceived").doc(userB));
    batch.delete(userBDoc.collection("likeSent").doc(userA));
    batch.delete(userBDoc.collection("likeReceived").doc(userA));

    await batch.commit();
  }
}
