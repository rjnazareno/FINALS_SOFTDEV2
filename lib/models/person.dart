import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  // Personal information
  String? uid;
  String? imageProfile;
  String? name;
  String? age;
  String? email;
  String? password;
  String? phoneNo;
  String? city;
  String? selectedGender;
  String? profileHeading;
  String? courseOrStrand;
  String? lookingForInaPartner;
  int? publishedTime;

  // Constructor
  Person({
    this.uid,
    this.imageProfile,
    this.name,
    this.email,
    this.password,
    this.age,
    this.phoneNo,
    this.city,
    this.selectedGender,
    this.profileHeading,
    this.lookingForInaPartner,
    this.courseOrStrand,
    this.publishedTime,
  });

  get gender => null;

  // Factory method to create a Person object from a Firestore document snapshot
  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(
      uid: dataSnapshot["uid"],
      name: dataSnapshot["name"],
      age: dataSnapshot["age"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      phoneNo: dataSnapshot["phoneNo"],
      city: dataSnapshot["city"],
      selectedGender: dataSnapshot["gender"],
      profileHeading: dataSnapshot["profileHeading"],
      courseOrStrand: dataSnapshot["courseOrStrand"],
      lookingForInaPartner: dataSnapshot["lookingForInaPartner"],
      publishedTime: dataSnapshot["publishedTime"],
      imageProfile: dataSnapshot["imageProfile"],
    );
  }

  // Convert Person object to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "imageProfile": imageProfile,
      "name": name,
      "age": age,
      "email": email,
      "password": password,
      "phoneNo": phoneNo,
      "city": city,
      "gender": selectedGender,
      "profileHeading": profileHeading,
      "courseOrStrand": courseOrStrand,
      "lookingForInaPartner": lookingForInaPartner,
      "publishedTime": publishedTime,
    };
  }
}
