import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
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

  factory Person.fromDataSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Person(
      uid: data["uid"],
      name: data["name"],
      age: data["age"],
      email: data["email"],
      password: data["password"],
      phoneNo: data["phoneNo"],
      city: data["city"],
      selectedGender: data["gender"],
      profileHeading: data["profileHeading"],
      courseOrStrand: data["courseOrStrand"],
      lookingForInaPartner: data["lookingForInaPartner"],
      publishedTime: data["publishedTime"],
      imageProfile: data["imageProfile"],
    );
  }

  get jobTitle => null;

  get gender => null;

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

  static Person fromDocument(DocumentSnapshot<Map<String, dynamic>> userDoc) {
    if (userDoc.data() == null) {
      throw Exception("Document data is null");
    }
    var data = userDoc.data()!;
    return Person(
      uid: data["uid"],
      name: data["name"],
      age: data["age"],
      email: data["email"],
      password: data["password"],
      phoneNo: data["phoneNo"],
      city: data["city"],
      selectedGender: data["gender"],
      profileHeading: data["profileHeading"],
      courseOrStrand: data["courseOrStrand"],
      lookingForInaPartner: data["lookingForInaPartner"],
      publishedTime: data["publishedTime"],
      imageProfile: data["imageProfile"],
    );
  }

}
