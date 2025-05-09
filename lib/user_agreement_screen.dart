import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key, required void Function() onAccepted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // white theme
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('User Agreement', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            _uaAgreementText,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

const String _uaAgreementText = '''
Welcome to UAmatch! 💙

We’re glad to have you here. This app was built with love for students and young adults from UA, but everyone is welcome to join and connect!

By using our app, you're agreeing to these simple community guidelines:

1. You must be at least 18 years old to use the app.
2. Respect others. Be kind, genuine, and considerate when chatting or matching.
3. No hate, harassment, or any form of abuse. Let's keep it safe and friendly.
4. Don’t use the platform for anything illegal or harmful.
5. Your information will be handled in line with our privacy policy.
6. We may remove users who violate these rules to keep the space positive.

We’re here to help you meet new people, find friendships, flings, or something more. 💫

Let’s make this a great place for everyone.

- UAmatch Team
''';
