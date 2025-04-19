import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwipingScreen extends StatefulWidget {
  const SwipingScreen({super.key});

  @override
  State<SwipingScreen> createState() => _SwipingScreenState();
}

class _SwipingScreenState extends State<SwipingScreen> {
  List<DocumentSnapshot> users = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    if (mounted) {
      setState(() {
        users = querySnapshot.docs;
      });
    }
  }

  void _showUserDetailsBottomSheet(Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(userData['imageProfile']),
            ),
            const SizedBox(height: 12),
            Text(
              userData['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Age: ${userData['age']}'),
            Text('City: ${userData['city']}'),
            Text('Gender: ${userData['gender']}'),
            Text('Course: ${userData['courseOrStrand']}'),
            Text('Looking For: ${userData['lookingForInaPartner']}'),
          ],
        ),
      ),
    );
  }

  void _swipeLeft() {
    if (currentIndex < users.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _swipeRight(Map<String, dynamic> userData) async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final likedUserId = userData['uid'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(likedUserId)
          .collection('likes')
          .doc(currentUserUid)
          .set({
        'likedBy': currentUserUid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You like this user!")),
      );

      _swipeLeft(); // Move to next user
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to like the user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swipe Profiles"),
        backgroundColor: Colors.redAccent,
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                final user = users[currentIndex].data() as Map<String, dynamic>;

                if (velocity < 0) {
                  // Swipe Left (Dislike)
                  _swipeLeft();
                } else if (velocity > 0) {
                  // Swipe Right (Like)
                  _swipeRight(user);
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < 0) {
                  final user = users[currentIndex].data() as Map<String, dynamic>;
                  _showUserDetailsBottomSheet(user);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    (users[currentIndex].data() as Map<String, dynamic>)['imageProfile'],
                    fit: BoxFit.cover,
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      (users[currentIndex].data() as Map<String, dynamic>)['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
