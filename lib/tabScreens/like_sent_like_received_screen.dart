import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeSentLikeReceivedScreen extends StatefulWidget {
  const LikeSentLikeReceivedScreen({super.key});

  @override
  State<LikeSentLikeReceivedScreen> createState() => _LikeSentLikeReceivedScreenState();
}

class _LikeSentLikeReceivedScreenState extends State<LikeSentLikeReceivedScreen> {
  bool showSent = true;
  final String currentUserID = FirebaseAuth.instance.currentUser?.uid ?? "";

  void _confirmDelete(String likedUserID) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Like"),
        content: const Text("Are you sure you want to remove this like?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection(showSent ? "likeSent" : "likeReceived")
          .doc(likedUserID)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  automaticallyImplyLeading: false,
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () => setState(() => showSent = true),
        child: Text(
          "My Likes",
          style: TextStyle(
            fontSize: 18, // ← slightly bigger
            fontWeight: FontWeight.bold,
            color: showSent ? Colors.black : Colors.black45,
          ),
        ),
      ),
      const SizedBox(width: 8),
      const Text("|", style: TextStyle(fontSize: 18, color: Colors.black54)),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => setState(() => showSent = false),
        child: Text(
          "Liked Me",
          style: TextStyle(
            fontSize: 18, // ← slightly bigger
            fontWeight: FontWeight.bold,
            color: !showSent ? Colors.black : Colors.black45,
          ),
        ),
      ),
    ],
  ),
),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserID)
            .collection(showSent ? "likeSent" : "likeReceived")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                showSent ? "You haven't liked anyone yet." : "No one liked you yet.",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final likesList = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: likesList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.6 / 4,
              ),
              itemBuilder: (context, index) {
                final likeDoc = likesList[index];
                final likedUserID = likeDoc.id;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(likedUserID)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const SizedBox();
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                userData["imageProfile"] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        userData["name"] ?? "Unknown",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color.fromARGB(255, 68, 68, 68),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        userData["city"] ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(likedUserID),
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: const Color.fromARGB(255, 114, 112, 112),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
