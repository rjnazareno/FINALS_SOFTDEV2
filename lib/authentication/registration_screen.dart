import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/controllers/authentication_controller.dart';
import 'package:ua_dating_app/widgets/custom_text_field_widget.dart';
import 'package:ua_dating_app/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final bool isGoogleUser;

  const RegistrationScreen({super.key, this.isGoogleUser = false});

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
  void initState() {
    super.initState();

    // Auto-fill email for Google user
    if (widget.isGoogleUser) {
      final currentUser = authController.currentUser;
      if (currentUser != null) {
        emailController.text = currentUser.email ?? '';
      }
    }
  }

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

              // Avatar Placeholder
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black12,
                backgroundImage: AssetImage("images/profile_avatar.png"),
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
              buildCustomTextField(emailController, "Email", Icons.email, isEnabled: !widget.isGoogleUser),

              // Show password only if not Google
              if (!widget.isGoogleUser)
                buildCustomTextField(passwordController, "Password", Icons.lock, isObscure: true),

              buildCustomTextField(ageController, "Age", Icons.cake),
              buildCustomTextField(phoneController, "Phone", Icons.phone),
              buildCustomTextField(cityController, "City", Icons.location_city),
              buildCustomTextField(genderController, "Gender", Icons.wc),
              buildCustomTextField(lookingForController, "Looking For", Icons.favorite),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_validateFields()) {
                    setState(() => isLoading = true);
                    try {
                      if (widget.isGoogleUser) {
                        await authController.storeGoogleUserProfile(
                          nameController.text.trim(),
                          ageController.text.trim(),
                          phoneController.text.trim(),
                          cityController.text.trim(),
                          genderController.text.trim(),
                          lookingForController.text.trim(),
                          genderController.text.trim(),
                        );
                      } else {
                        await authController.createNewUserAccount(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                          ageController.text.trim(),
                          phoneController.text.trim(),
                          cityController.text.trim(),
                          genderController.text.trim(),
                          lookingForController.text.trim(),
                          genderController.text.trim(),
                          "additionalArgumentValue", // Replace with the actual value for the 10th argument
                        );
                      }
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

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        (!widget.isGoogleUser && passwordController.text.isEmpty) ||
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
