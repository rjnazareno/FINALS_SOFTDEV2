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
        .set({
          "timestamp": FieldValue.serverTimestamp(),
          "deleted": false,
        });
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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipOval(
                child: Container(
                  width: 90, // ⬅️ Increased size
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: hasImage
                          ? NetworkImage(person.imageProfile!)
                          : const AssetImage('images/placeholder.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Match count badge only on the first item
              if (index == 0 && matches.length > 1)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${matches.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            person.name ?? '',
      
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black,),
            
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
Widget _buildMessageItem(Person person) {
  final chatId = _getChatId(currentUserID, person.uid!);

  return Dismissible(
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
        matches.removeWhere((p) => p.uid == person.uid);
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
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String subtitle = "Tap to open chat";

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          if (docs.isNotEmpty) {
            final message = docs.first;
            final data = message.data() as Map<String, dynamic>;

            final text = data['text'] ?? "";
            final senderId = data['senderId'] ?? "";

            subtitle = senderId == currentUserID ? "You: $text" : text;
          }
        } else if (snapshot.hasError) {
          subtitle = "Could not load chat";
        }

        return ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  leading: CircleAvatar(
    radius: 30, // ⬅️ Increased size
    backgroundImage: person.imageProfile != null
        ? NetworkImage(person.imageProfile!)
        : const AssetImage('images/placeholder.png') as ImageProvider,
  ),
  title: Text(
    person.name ?? 'No Name',
    style: TextStyle(
      color: titleColor,
      fontSize: 18, // ⬅️ Bigger title
      fontWeight: FontWeight.w600,
    ),
  ),
  subtitle: Text(
    subtitle,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 16, // ⬅️ Bigger subtitle
    ),
  ),
  trailing: const Icon(
    Icons.chevron_right,
    size: 28, // ⬅️ Bigger icon
    color: Colors.grey,
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(person: person)),
    );
  },
);
      },
    ),
  );
}


  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
   appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  automaticallyImplyLeading: false, // Hide default back button
  title: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset('images/logo.png', width: 32, height: 32),
      const SizedBox(width: 8),
      const Text(
        'UAmatch',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ],
  ),
  centerTitle: true,
),
      body: FutureBuilder<void>(
        future: _loadMatchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Text(
    "Your Matches ",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
  ),
),
SizedBox(
  height: 120,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: matches.isNotEmpty ? matches.length : 1, // Always show at least one item
    itemBuilder: (context, index) {
      if (matches.isEmpty) {
        // Default placeholder shown when no matches exist
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ClipOval(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "No matches",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      } else {
        // Show matches if there are any
        return _buildMatchItem(matches[index], index);
      }
    },
  ),
),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(thickness: 1.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Messages 💬",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
                ),
              ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          "No messages yet. Start chatting!",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) => _buildMessageItem(messages[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
