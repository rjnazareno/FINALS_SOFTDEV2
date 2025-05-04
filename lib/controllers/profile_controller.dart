import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ua_dating_app/main.dart';
import 'package:ua_dating_app/models/person.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, List<Person>>((ref) {
  final authUser = ref.watch(firebaseAuthProvider).value;
  return ProfileController(authUser?.uid, ref);
});

class ProfileController extends StateNotifier<List<Person>> {
  final Ref ref;
  String? currentUserID;

  ProfileController(this.currentUserID, this.ref) : super([]) {
    if (currentUserID != null) _init();
  }

  Set<String> dislikedIds = {};
  Set<String> likedIds = {};
  List<Person> _allProfiles = [];
  List<Person> temporarilyDislikedProfiles = [];

  String? genderFilter;
  int? minAgeFilter;
  int? maxAgeFilter;
  String? cityFilter;

  final List<StreamSubscription> _subscriptions = [];

  void _init() {
    _subscriptions.add(
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("disliked")
          .snapshots()
          .listen((snapshot) {
        dislikedIds = snapshot.docs.map((doc) => doc.id).toSet();
        _filterProfiles();
      }),
    );

    _subscriptions.add(
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("likeSent")
          .snapshots()
          .listen((snapshot) {
        likedIds = snapshot.docs.map((doc) => doc.id).toSet();
        _filterProfiles();
      }),
    );

    _subscriptions.add(
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: currentUserID)
          .snapshots()
          .listen((querySnapshot) {
        _allProfiles = querySnapshot.docs
            .map((doc) => Person.fromDataSnapshot(doc))
            .toList();
        _filterProfiles();
      }),
    );
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

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
    if (currentUserID == null) return;

    final currentUserRef = FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef = FirebaseFirestore.instance.collection("users").doc(toUserID);

    final alreadyLiked = await isAlreadyLiked(toUserID);

    if (!alreadyLiked) {
      await toUserRef.collection("likeReceived").doc(currentUserID).set({
        "name": senderName,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection("likeSent").doc(toUserID).set({
        "timestamp": FieldValue.serverTimestamp(),
      });

      final receivedLikeDoc =
          await currentUserRef.collection("likeReceived").doc(toUserID).get();

      if (receivedLikeDoc.exists) {
        await currentUserRef.collection("matches").doc(toUserID).set({
          "timestamp": FieldValue.serverTimestamp(),
        });
        await toUserRef.collection("matches").doc(currentUserID).set({
          "timestamp": FieldValue.serverTimestamp(),
        });

        await removeLikesBetween(currentUserID!, toUserID);
      }
    }

    _removeProfileLocally(toUserID);
  }

  Future<void> dislikeUser(String toUserID) async {
    if (currentUserID == null) return;

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
    if (temporarilyDislikedProfiles.isEmpty || currentUserID == null) return;

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
    if (currentUserID == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("likeSent")
        .doc(toUserID)
        .get();

    return doc.exists;
  }

  Future<List<Person>> getMatchedUsers() async {
    if (currentUserID == null) return [];

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
