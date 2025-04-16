import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/authentication/registration_screen.dart';
import 'package:ua_dating_app/controllers/authentication_controller.dart';
import 'package:ua_dating_app/home_screen.dart';
import 'package:ua_dating_app/widgets/custom_text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();

  final authController = Get.find<AuthenticationController>();
  bool showProgressBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset('images/logo.png', width: 200),
                const SizedBox(height: 20),
                const Text('Welcome',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 68, 68, 68))),
                const SizedBox(height: 10),
                const Text('Please login to find your match',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
                const SizedBox(height: 40),
                CustomTextFieldWidget(
                  emailTextEditingController,
                  labelText: 'Email',
                  iconData: Icons.email_outlined,
                  isObscure: false,
                  isEnabled: true,
                ),
                const SizedBox(height: 20),
                CustomTextFieldWidget(
                  passwordTextEditingController,
                  labelText: 'Password',
                  iconData: Icons.lock_outline,
                  isObscure: true,
                  isEnabled: true,
                ),
                const SizedBox(height: 30),
                showProgressBar
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleEmailPasswordLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1.2)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or", style: TextStyle(color: Colors.grey)),
                    ),
                    const Expanded(child: Divider(thickness: 1.2)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Image.asset("images/google.png", width: 24),
                    label: const Text("Sign in with Google", style: TextStyle(color: Colors.grey)),
                    onPressed: _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => const RegistrationScreen(isGoogleUser: false));
                  },
                  child: const Text(
                    "Don't have an account? Create here",
                    style: TextStyle(fontSize: 16, decoration: TextDecoration.underline, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailPasswordLogin() async {
    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Missing Information",
        "Please fill in both email and password.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => showProgressBar = true);

    try {
      await authController.loginUser(email, password);
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString().replaceAll("Exception: ", ""),
        // ignore: deprecated_member_use
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => showProgressBar = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => showProgressBar = true);
    try {
      await authController.signInWithGoogle();
      bool isProfileExists = await authController.checkUserProfileExists();
      if (isProfileExists) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.to(() => const RegistrationScreen(isGoogleUser: true));
      }
    } catch (e) {
      Get.snackbar("Google Sign-In Failed", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => showProgressBar = false);
    }
  }
}
