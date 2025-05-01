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

  String? genderFilter;
  int? minAgeFilter;
  int? maxAgeFilter;
  String? cityFilter;

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

  // Set gender filter: "Male", "Female", or null for all
  void setGenderFilter(String? gender) {
    genderFilter = gender;
    _filterProfiles();
  }

  void setAgeFilter(int? minAge, int? maxAge) {
    minAgeFilter = minAge;
    maxAgeFilter = maxAge;
    _filterProfiles();
  }

  void setCityFilter(String? city) {
    cityFilter = city;
    _filterProfiles();
  }

  Future<void> _filterProfiles() async {
    final filtered = await Future.wait(_allProfiles.map((person) async {
      final uid = person.uid;
      final matchesGender = genderFilter == null ||
          genderFilter?.toLowerCase() == person.selectedGender?.toLowerCase();

      final matchesAge = (minAgeFilter == null || ((person.age as int?) ?? 0) >= minAgeFilter!) &&
          (maxAgeFilter == null || ((person.age as int?) ?? 100) <= maxAgeFilter!);

      final matchesCity = cityFilter == null ||
          cityFilter!.toLowerCase() == person.city?.toLowerCase();

      if (uid != null &&
          !dislikedIds.contains(uid) &&
          !likedIds.contains(uid) &&
          !await isMatchOngoing(uid) &&
          matchesGender &&
          matchesAge &&
          matchesCity) {
        return person;
      }
      return null;
    }));

    state = filtered.whereType<Person>().toList();
  }

  Future<bool> isMatchOngoing(String userId) async {
    final match1 = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("matches")
        .doc(userId)
        .get();

    final match2 = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("matches")
        .doc(currentUserID)
        .get();

    return match1.exists || match2.exists;
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

    final profile =
        _allProfiles.firstWhere((p) => p.uid == toUserID, orElse: () => Person(uid: null));
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
