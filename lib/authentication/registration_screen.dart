// ignore_for_file: depend_on_referenced_packages, await_only_futures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/controllers/authentication_controller.dart';
import 'package:ua_dating_app/widgets/custom_text_field_widget.dart';
import 'package:ua_dating_app/home_screen.dart';
import 'package:ua_dating_app/user_agreement_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final bool isGoogleUser;
  final String email;

  const RegistrationScreen({
    super.key,
    required this.email,
    this.isGoogleUser = false,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController lookingForController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController otherCourseController = TextEditingController();

  String? selectedGender;
  String? selectedCourseOrStrand;
  bool isLoading = false;
  bool agreedToTerms = false;

  final List<String> courseStrandOptions = [
    "Accountancy",
    "Architecture",
    "Communication",
    "Business Administration",
    "Civil Engineering",
    "Computer Engineering",
    "Criminology",
    "Early Childhood Education",
    "Elementary Education",
    "Hospitality Management",
    "Human Services",
    "Industrial Engineering",
    "Information Technology",
    "Library and Information Science",
    "Nursing",
    "Pharmacy",
    "Physical Education",
    "Psychology",
    "Secondary Education",
    "Tourism Management",
    "Others", 
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isGoogleUser) {
      emailController.text = widget.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text("Create an Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68))),
              const Text("to get started", style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 60,
                backgroundImage: authController.profileImage != null
                    ? FileImage(authController.profileImage!)
                    : const AssetImage("images/profile_avatar.png") as ImageProvider,
                backgroundColor: Colors.black12,
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.blue),
                    onPressed: () => authController.pickImageFileFromCamera(context),
                    tooltip: "Take Photo",
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.green),
                    onPressed: () => authController.pickImageFileFromGallery(context),
                    tooltip: "Choose from Gallery",
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.center,
                child: Text("Personal Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68))),
              ),
              const SizedBox(height: 12),

              buildCustomTextField(nameController, "Name", Icons.person),
              buildCustomTextField(emailController, "Email", Icons.email, isEnabled: !widget.isGoogleUser),
              if (!widget.isGoogleUser)
                buildCustomTextField(passwordController, "Password", Icons.lock, isObscure: true),
              buildCustomTextField(ageController, "Age", Icons.cake),
              buildCustomTextField(phoneController, "Phone", Icons.phone),
              buildCustomTextField(cityController, "City", Icons.location_city),

              buildDropdownField(
                label: "Gender",
                icon: Icons.wc,
                value: selectedGender,
                onChanged: (value) => setState(() => selectedGender = value),
                items: ['Male', 'Female'],
              ),

              buildDropdownField(
                label: "Course/Strand",
                icon: Icons.school,
                value: selectedCourseOrStrand,
                onChanged: (value) {
                  setState(() {
                    selectedCourseOrStrand = value;
                    if (value != "Others") {
                      otherCourseController.clear();
                    }
                  });
                },
                items: courseStrandOptions,
              ),

              if (selectedCourseOrStrand == "Others")
                buildCustomTextField(otherCourseController, "Please specify your Course/Strand", Icons.edit),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.center,
                child: Text("About Me", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68))),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: bioController,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  labelText: "Bio",
                  hintText: "Tell us something about yourself",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(color: Color.fromARGB(221, 90, 90, 90)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              buildCustomTextField(lookingForController, "Looking For (Love,Fling,Friend)", Icons.favorite),
              buildCustomTextField(interestController, "Interests (Music,Movies,Sports)", Icons.interests),

              const SizedBox(height: 16),
              CheckboxListTile(
                value: agreedToTerms,
                onChanged: (value) => setState(() => agreedToTerms = value!),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserAgreementScreen(onAccepted: () => Navigator.pop(context)),
                      ),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_validateFields()) {
                    setState(() => isLoading = true);
                    await Future.delayed(const Duration(seconds: 2));

                    try {
                      final cleanedLookingFor = _cleanCommaSeparated(lookingForController.text);
                      final cleanedInterests = _cleanCommaSeparated(interestController.text);
                      final cleanedBio = bioController.text.trim();

                      final courseValue = selectedCourseOrStrand == "Others"
                          ? otherCourseController.text.trim()
                          : selectedCourseOrStrand ?? '';

                      bool success = false;

                      if (widget.isGoogleUser) {
                        final imageUrl = authController.profileImage != null
                            ? await authController.uploadImageToStorage(authController.profileImage!)
                            : '';

                        await authController.storeGoogleUserProfile(
                          uid: authController.currentUser?.uid ?? '',
                          email: widget.email,
                          name: nameController.text.trim(),
                          age: ageController.text.trim(),
                          phoneNo: phoneController.text.trim(),
                          city: cityController.text.trim(),
                          courseOrStrand: courseValue,
                          lookingForInaPartner: cleanedLookingFor,
                          gender: selectedGender!,
                          imageUrl: imageUrl,
                          bio: cleanedBio,
                          interests: cleanedInterests,
                          hasAcceptedAgreement: true,
                        );
                        success = true;
                      } else {
                        success = await authController.createNewUserAccount(
                          context,
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                          ageController.text.trim(),
                          phoneController.text.trim(),
                          cityController.text.trim(),
                          courseValue,
                          cleanedLookingFor,
                          selectedGender!,
                          authController.profileImage?.path ?? "",
                          cleanedBio,
                          cleanedInterests,
                        );

                        if (success && authController.currentUser != null) {
                          await authController.saveAgreementToFirestore();
                        }
                      }

                      if (success && mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      setState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 21, 101, 221),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text("Register", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text(
                  "Already have an account? Sign In",
                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 68, 68, 68)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomTextFieldWidget(
        controller,
        labelText: label,
        iconData: icon,
        isObscure: isObscure,
        isEnabled: isEnabled,
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 68, 68, 68)),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 12.0),
            labelText: label,
            prefixIcon: Icon(icon, color: const Color.fromARGB(255, 161, 161, 161)),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 20, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.grey,
        ),
      ),
    );
  }

  bool _validateFields() {
    final authController = ref.read(authControllerProvider);

    if (authController.profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload a profile picture")));
      return false;
    }

    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must agree to the Terms and Conditions")));
      return false;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        (!widget.isGoogleUser && passwordController.text.isEmpty) ||
        ageController.text.isEmpty ||
        phoneController.text.isEmpty ||
        cityController.text.isEmpty ||
        selectedGender == null ||
        selectedCourseOrStrand == null ||
        (selectedCourseOrStrand == "Others" && otherCourseController.text.isEmpty) ||
        lookingForController.text.isEmpty ||
        bioController.text.isEmpty ||
        interestController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return false;
    }

    return true;
  }

  String _cleanCommaSeparated(String input) {
    return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
  }
}
