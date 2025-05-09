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
    ref.invalidate(userProvider); // This is usually safe, but add mounted check above to be thorough
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: screenIndex == 3
          ? Drawer(
              child: ListView(
  padding: EdgeInsets.zero,
  children: [
    DrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 1, 34, 70), // Keep the dark blue color
      ),
      child: Center(
        child: Text(
          'UAmatch', // Text for the title
          style: TextStyle(
            fontSize:60, // Big size
            fontWeight: FontWeight.bold, // Bold text
            fontFamily: 'Jua', // Use Jua font
            color: Color.fromARGB(255, 194, 232, 250), // Light blue color
          ),
        ),
      ),
    ),

    ListTile(
      leading: const Icon(Icons.email_outlined, color: Color.fromARGB(255, 217, 255, 1)),
      title: Text(
        FirebaseAuth.instance.currentUser?.email ?? '',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 241, 239, 239),
        ),
      ),
    ),
    ListTile(
      leading: const Icon(Icons.info_outline, color: Color.fromARGB(255, 217, 255, 1)),
      title: const Text(
        'About Us',
        style: TextStyle(

          fontSize: 16,
          color: Colors.white,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        showAboutDialog(
          context: context,
          applicationName: 'UAMatch',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2025 UA Inc.',
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Like a pelican finding its flock, UAMatch connects university students to make meaningful matches. This is a space where you can find your place, whether it’s for friendship, love, or fresh new connections. 🕊️',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'We believe everyone deserves to be seen, heard, and connected in their own way. So take a step in the right direction and let us help you make the connection of a lifetime.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
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
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
      onTap: () => _confirmLogout(context),
    ),
  ],
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
        selectedItemColor: const Color.fromARGB(255, 82, 200, 255),
        unselectedItemColor: Colors.grey,
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
