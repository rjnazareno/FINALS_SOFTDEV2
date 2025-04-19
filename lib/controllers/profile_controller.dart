import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/models/person.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);

  List<Person> get allUsersProfileList => usersProfileList.value;

  @override
  void onInit() {
    super.onInit();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    usersProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: currentUser.uid)
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
}
