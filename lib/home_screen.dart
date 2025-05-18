import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ua_dating_app/tabScreens/like_sent_like_received_screen.dart';
import 'package:ua_dating_app/tabScreens/match_screen.dart';
import 'package:ua_dating_app/tabScreens/swiping_screen.dart';
import 'package:ua_dating_app/tabScreens/user_details_screen.dart';
import 'package:ua_dating_app/authentication/login_screen.dart';
import 'package:ua_dating_app/providers/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int screenIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> tabScreensList = [
    const SwipingScreen(),
    const MatchScreen(),
    const LikeSentLikeReceivedScreen(),
    const UserDetailsScreen(),
  ];

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ref.invalidate(userProvider);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
        "Are you sure you want to delete your account? This action cannot be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );

  if (!context.mounted) return;

  if (confirm == true) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance;

      if (user != null) {
        final uid = user.uid;

        // Delete user's Firestore document
        await firestore.collection('users').doc(uid).delete();

        // (Optional) Delete related subcollections if any
        // For example:
        // await _deleteCollection(firestore.collection('users').doc(uid).collection('matches'));

        // Delete Firebase Auth account
        await user.delete();

        ref.invalidate(userProvider);

        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Failed to delete account. Please re-login and try again.";
      if (e.code == 'requires-recent-login') {
        message = "Please log in again before deleting your account.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: screenIndex == 3
          ? Drawer(
              child: Container(
                color: const Color.fromARGB(255, 247, 247, 248), // Light grey background
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          SizedBox(
                            height: 200,
                            child: Image.asset(
                              'images/ua.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email_outlined,
                                color: Color.fromARGB(255, 21, 101, 221)),
                            title: Text(
                              FirebaseAuth.instance.currentUser?.email ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline,
                                color: Color.fromARGB(255, 21, 101, 221)),
                            title: const Text(
                              'About Us',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              showAboutDialog(
                                context: context,
                                applicationName: 'UAmatch',
                                applicationVersion: '1.0.0',
                                applicationLegalese: '© 2025 UA Inc.',
                                children: [
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'We are 3rd year Computer Engineering students from UA, and we created this app — UAmatch — especially for the UA community.',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 241, 238, 238),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Our goal is to bring students closer together by helping them find meaningful connections, whether it’s friendship or something more. We poured our hearts (and code) into this.',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 240, 239, 239),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'We truly hope you enjoy using UAmatch as much as we enjoyed building it for you.',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 247, 243, 243),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout,
                                color: Colors.redAccent),
                            title: const Text('Logout',
                                style: TextStyle(color: Colors.redAccent)),
                            onTap: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: ListTile(
                        leading: const Icon(Icons.delete, color: Colors.redAccent),
                        title: const Text('Delete Account',
                            style: TextStyle(color: Colors.redAccent)),
                        onTap: () => _confirmDeleteAccount(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      appBar: screenIndex == 3
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                "About Me",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ],
            )
          : null,
      body: tabScreensList[screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: screenIndex,
        selectedItemColor: const Color.fromARGB(255, 21, 101, 221),
        unselectedItemColor: const Color.fromARGB(255, 95, 95, 95),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => screenIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_up),
            label: 'Likes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
