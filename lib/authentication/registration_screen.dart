import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/controllers/authentication_controller.dart';
import 'package:ua_dating_app/widgets/custom_text_field_widget.dart';
import 'package:ua_dating_app/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required bool isGoogleUser});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController lookingForController = TextEditingController();

  final authController = Get.find<AuthenticationController>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68)),
              ),
              const Text("to get started", style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 20),
              Obx(() {
                final imageFile = authController.profileImage;
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black12,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile)
                      : const AssetImage("images/profile_avatar.png") as ImageProvider,
                );
              }),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: authController.pickImageFileFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: authController.pickImageFileFromGallery,
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Personal Info",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68)),
                ),
              ),
              const SizedBox(height: 12),
              buildCustomTextField(nameController, "Name", Icons.person),
              buildCustomTextField(emailController, "Email", Icons.email),
              buildCustomTextField(passwordController, "Password", Icons.lock, isObscure: true),
              buildCustomTextField(ageController, "Age", Icons.cake),
              buildCustomTextField(phoneController, "Phone", Icons.phone),
              buildCustomTextField(cityController, "City", Icons.location_city),
              buildCustomTextField(genderController, "Gender", Icons.wc),
              buildCustomTextField(lookingForController, "Looking For", Icons.favorite),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (authController.profileImage == null) {
                    Get.snackbar("Image Missing", "Please select an image.");
                    return;
                  }
                  if (_validateFields()) {
                    setState(() => isLoading = true);
                    try {
                      await authController.createNewUserAccount(
                        emailController.text,
                        passwordController.text,
                        "", // imagePath not used here
                        nameController.text,
                        ageController.text,
                        phoneController.text,
                        cityController.text,
                        genderController.text,
                        lookingForController.text,
                        "",
                      );
                      Get.offAll(() => const HomeScreen());
                    } catch (e) {
                      Get.snackbar("Error", e.toString());
                    } finally {
                      setState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text("Register", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.to(() => const LoginScreen()),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomTextFieldWidget(
        controller,
        labelText: label,
        iconData: icon,
        isObscure: isObscure, isEnabled: true,
      ),
    );
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        ageController.text.isEmpty ||
        phoneController.text.isEmpty ||
        cityController.text.isEmpty ||
        genderController.text.isEmpty ||
        lookingForController.text.isEmpty) {
      Get.snackbar("Validation Error", "Please fill in all fields");
      return false;
    }
    return true;
  }
}