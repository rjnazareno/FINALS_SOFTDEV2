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
  String? bio;
  String? interests;
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
    this.courseOrStrand,
    this.lookingForInaPartner,
    this.bio,
    this.interests,
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
      bio: data["bio"],
      interests: data["interests"],
      publishedTime: data["publishedTime"],
      imageProfile: data["imageProfile"],
    );
  }

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
      "bio": bio,
      "interests": interests,
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
      bio: data["bio"],
      interests: data["interests"],
      publishedTime: data["publishedTime"],
      imageProfile: data["imageProfile"],
    );
  }


  String get safeBio => bio ?? "";
  String get safeInterests => interests ?? "";
  String get safePhoneNo => phoneNo ?? "";
}
