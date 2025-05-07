import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ua_dating_app/controllers/profile_controller.dart';
import 'package:ua_dating_app/models/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  List<Person> matches = [];
  List<Person> messages = [];
  late final Future<void> _loadMatchesFuture;

  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  final Color titleColor = const Color.fromARGB(255, 68, 68, 68);

  @override
  void initState() {
    super.initState();
    _loadMatchesFuture = _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final fetchedMatches = await ref.read(profileControllerProvider.notifier).getMatchedUsers();
    final messagedSnapshots = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messaged")
        .get();

    final messagedUserIDs = <String>{};
    final deletedUserIDs = <String>{};

    for (var doc in messagedSnapshots.docs) {
      final isDeleted = doc.data()["deleted"] == true;
      if (isDeleted) {
        deletedUserIDs.add(doc.id);
      } else {
        messagedUserIDs.add(doc.id);
      }
    }

    final messageList = fetchedMatches.where((user) => messagedUserIDs.contains(user.uid)).toList();
    final matchList = fetchedMatches
        .where((user) => !messagedUserIDs.contains(user.uid) && !deletedUserIDs.contains(user.uid))
        .toList();

    setState(() {
      matches = matchList;
      messages = messageList;
    });
  }

  Future<void> _saveMessagedUser(String otherUserId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection("messaged")
        .doc(otherUserId)
        .set({"timestamp": FieldValue.serverTimestamp(), "deleted": false});
  }

  void _startChat(Person person) async {
    setState(() {
      matches.removeWhere((p) => p.uid == person.uid);
      if (!messages.any((p) => p.uid == person.uid)) {
        messages.add(person);
      }
    });

    await _saveMessagedUser(person.uid!);
    ref.read(profileControllerProvider.notifier).removeLikesBetween(person.uid!, currentUserID);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(person: person)),
      );
    }
  }

  Widget _buildMatchItem(Person person, int index) {
    final hasImage = person.imageProfile != null;

    return GestureDetector(
      onTap: () => _startChat(person),
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: hasImage
                          ? NetworkImage(person.imageProfile!)
                          : const AssetImage('images/placeholder.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              person.name ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Person person) {
    final chatId = _getChatId(currentUserID, person.uid!);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String subtitle = "Tap to open chat";

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final message = snapshot.data!.docs.first;
          final data = message.data() as Map<String, dynamic>;
          final text = data['text'] ?? "";
          final senderId = data['senderId'] ?? "";
          subtitle = senderId == currentUserID ? "You: $text" : text;
        } else if (snapshot.hasError) {
          subtitle = "Could not load chat";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Dismissible(
            key: Key(person.uid!),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete_forever, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Chat"),
                  content: const Text("Are you sure you want to permanently delete this chat?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                  ],
                ),
              );
            },
            onDismissed: (_) async {
              setState(() {
                messages.removeWhere((p) => p.uid == person.uid);
              });

              final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);
              final messageSnapshot = await chatRef.collection("messages").get();
              for (var doc in messageSnapshot.docs) {
                await doc.reference.delete();
              }
              await chatRef.delete();

              final usersRef = FirebaseFirestore.instance.collection("users");
              await usersRef
                  .doc(currentUserID)
                  .collection("messaged")
                  .doc(person.uid!)
                  .set({"deleted": true}, SetOptions(merge: true));
              await usersRef
                  .doc(person.uid!)
                  .collection("messaged")
                  .doc(currentUserID)
                  .set({"deleted": true}, SetOptions(merge: true));

              await ref.read(profileControllerProvider.notifier).removeLikesBetween(currentUserID, person.uid!);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: person.imageProfile != null
                      ? NetworkImage(person.imageProfile!)
                      : const AssetImage('images/placeholder.png') as ImageProvider,
                ),
                title: Text(
                  person.name ?? 'No Name',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 26),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen(person: person)),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<void>(
        future: _loadMatchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Chats",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Your Matches", matches.length),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: matches.isNotEmpty ? matches.length : 1,
                    itemBuilder: (context, index) {
                      if (matches.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            children: [
                              CircleAvatar(radius: 35, backgroundImage: AssetImage('images/placeholder.png')),
                              SizedBox(height: 6),
                              Text("No matches", style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        );
                      } else {
                        return _buildMatchItem(matches[index], index);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildSectionHeader("Chats", messages.length),
                const SizedBox(height: 8),
                Expanded(
                  child: messages.isEmpty
                      ? Center(child: Text("No messages yet. Start chatting!", style: TextStyle(color: Colors.grey[600], fontSize: 16)))
                      : ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) => _buildMessageItem(messages[index]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Text("$count", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
