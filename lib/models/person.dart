import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  // Personal information
  String? imageProfile;
  String? name;
  String? age;
  String? email;
  String? password;
  String? phoneNo;
  String? city;
  String? gender;
  String? profileHeading;
  String? lookingForInaPartner;
  int? publishedTime;

  // Constructor
  Person({
    this.imageProfile,
    this.name,
    this.email,
    this.password,
    this.age,
    this.phoneNo,
    this.city,
    this.gender,
    this.profileHeading,
    this.lookingForInaPartner,
    this.publishedTime,
  });

  // Factory method to create a Person object from a Firestore document snapshot
  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(
      name: dataSnapshot["name"],
      age: dataSnapshot["age"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      phoneNo: dataSnapshot["phoneNo"],
      city: dataSnapshot["city"],
      gender: dataSnapshot["gender"],
      profileHeading: dataSnapshot["profileHeading"],
      lookingForInaPartner: dataSnapshot["lookingForInaPartner"],
      publishedTime: dataSnapshot["publishedTime"],
      imageProfile: dataSnapshot["imageProfile"],
    );
  }

  // Convert Person object to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      "imageProfile": imageProfile,
      "name": name,
      "age": age,
      "email": email,
      "password": password,
      "phoneNo": phoneNo,
      "city": city,
      "gender": gender,
      "profileHeading": profileHeading,
      "lookingForInaPartner": lookingForInaPartner,
      "publishedTime": publishedTime,
    };
  }
}
