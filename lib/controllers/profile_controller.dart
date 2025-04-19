import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/models/person.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);

  List<Person> get allUsersProfileList => usersProfileList.value;

  final String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();

    if (currentUserID.isEmpty) return;

    usersProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: currentUserID)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Person> profilesList = [];

        for (var doc in querySnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(doc));
        }

        return profilesList;
      }),
    );
  }

  Future<void> likeSentAndLikeReceived(String toUserID, String senderName) async {
    final currentUserRef =
        FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final toUserRef = FirebaseFirestore.instance.collection("users").doc(toUserID);

    final doc = await toUserRef.collection("likeReceived").doc(currentUserID).get();

    if (doc.exists) {
      // UNLIKE: Remove from both
      await toUserRef.collection("likeReceived").doc(currentUserID).delete();
      await currentUserRef.collection("likeSent").doc(toUserID).delete();
    } else {
      // LIKE: Add to both
      await toUserRef.collection("likeReceived").doc(currentUserID).set({
        "name": senderName,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection("likeSent").doc(toUserID).set({
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    update(); // Triggers UI update if needed
  }
}
