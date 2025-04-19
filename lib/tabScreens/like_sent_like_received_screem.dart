import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeSentLikeReceivedScreem extends StatefulWidget {
  const LikeSentLikeReceivedScreem({super.key});

  @override
  State<LikeSentLikeReceivedScreem> createState() =>
      _LikeSentLikeReceivedScreemState();
}

class _LikeSentLikeReceivedScreemState
    extends State<LikeSentLikeReceivedScreem> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<List<DocumentSnapshot>> fetchUsersFromLikes(String path, String field) async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likes')
        .get();

    final userIds = likesSnapshot.docs.map((doc) => doc['likedBy']).toList();

    if (userIds.isEmpty) return [];

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return usersSnapshot.docs;
  }

  void _showProfileBottomSheet(Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userData['imageProfile']),
            ),
            const SizedBox(height: 12),
            Text(userData['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  Widget buildUserCard(DocumentSnapshot userDoc) {
    final userData = userDoc.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () => _showProfileBottomSheet(userData),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(userData['imageProfile']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                userData['name'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTab(bool isSentTab) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: isSentTab
          ? fetchUsersFromLikes('likes', 'likedTo') // Sent Likes
          : fetchReceivedLikes(), // Received Likes
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userDocs = snapshot.data!;

        if (userDocs.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          itemCount: userDocs.length,
          itemBuilder: (context, index) => buildUserCard(userDocs[index]),
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> fetchReceivedLikes() async {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('likes')
        .where('likedBy', isEqualTo: currentUserId)
        .get();
        return snapshot.docs;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Likes'),
        backgroundColor: Colors.redAccent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTab(true),
          buildTab(false),
        ],
      ),
    );
  }
}
