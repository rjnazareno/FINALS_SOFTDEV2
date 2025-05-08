// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrumlab_flutter_tindercard/scrumlab_flutter_tindercard.dart';
import 'package:ua_dating_app/controllers/profile_controller.dart';

class SwipingScreen extends ConsumerStatefulWidget {
  const SwipingScreen({super.key});

  @override
  ConsumerState<SwipingScreen> createState() => _SwipingScreenState();
}

class _SwipingScreenState extends ConsumerState<SwipingScreen> {
  @override
  Widget build(BuildContext context) {
    final profileController = ref.watch(profileControllerProvider.notifier);
    final profiles = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Padding(
  padding: const EdgeInsets.symmetric(vertical: 5.0), // Increased vertical space for the entire Row
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0), // More horizontal padding on the left
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4), // More space between the two texts
            Text(
              'UA',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

    ],
  ),
),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: profiles.isEmpty
                    ? const Center(child: Text("No profiles found."))
                    : TinderSwapCard(
                        orientation: AmassOrientation.bottom,
                        totalNum: profiles.length,
                        stackNum: 3,
                        swipeEdge: 4.0,
                        maxWidth: MediaQuery.of(context).size.width * 0.95,
                        maxHeight: MediaQuery.of(context).size.height * 0.65,
                        minWidth: MediaQuery.of(context).size.width * 0.85,
                        minHeight: MediaQuery.of(context).size.height * 0.55,
                       cardBuilder: (context, index) {
  final profile = profiles[index];

  return Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Container(
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Prevent overscroll to black
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top image with overlay
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.62,
                  width: double.infinity,
                  child: Image.network(
                    profile.imageProfile ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.error, color: Colors.white)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.62,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 38, // Raised a bit higher
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${profile.age ?? '??'} • ${profile.city ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Details section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((profile.bio ?? '').trim().isNotEmpty) ...[
                    const Text(
                      "Bio",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 68, 68, 68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
  profile.bio!,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold, // or FontWeight.bold
    fontFamily: 'Roboto',
    color: Colors.black,
  ),
  textAlign: TextAlign.start,
),

                    const SizedBox(height: 24),
                  ],
                  if ((profile.lookingForInaPartner ?? '').trim().isNotEmpty) ...[
                    const Text(
                      "Looking For",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 68, 68, 68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.lookingForInaPartner!
    .split(',')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .map((item) => _infoChip(item))
    .toList(),

                    ),
                    const SizedBox(height: 24),
                  ],
               if ((profile.interests ?? '').trim().isNotEmpty) ...[
  const Text(
    "Interests",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 68, 68, 68),
    ),
  ),
  const SizedBox(height: 8),
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: profile.interests!
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map((item) => _infoChip(item))
        .toList(),
  ),
  const SizedBox(height: 24),
],

                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

},

                        swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {},
                        swipeCompleteCallback: (CardSwipeOrientation orientation, int index) async {
                          final swipedProfile = profiles[index];

                          if (orientation == CardSwipeOrientation.right) {
                            final alreadyLiked = await profileController
                                .isAlreadyLiked(swipedProfile.uid ?? '');
                            if (!alreadyLiked) {
                              await profileController.likeSentAndLikeReceived(
                                swipedProfile.uid ?? '',
                                swipedProfile.name ?? 'Unknown',
                              );
                            }
                          } else if (orientation == CardSwipeOrientation.left) {
                            await profileController.dislikeUser(swipedProfile.uid ?? '');
                          }
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconButton('images/back.png', size: 60, onTap: () async {
                  final profile = profiles.isNotEmpty ? profiles[0] : null;
                  if (profile != null) {
                    await profileController.dislikeUser(profile.uid ?? '');
                  }
                }),
                const SizedBox(width: 16),
                _iconButton('images/like.png', size: 90, onTap: () async {
                  final profile = profiles.isNotEmpty ? profiles[0] : null;
                  if (profile != null) {
                    final alreadyLiked = await profileController
                        .isAlreadyLiked(profile.uid ?? '');

                    if (!alreadyLiked) {
                      await profileController.likeSentAndLikeReceived(
                        profile.uid ?? '',
                        profile.name ?? 'Unknown',
                      );
                    }
                  }
                }),
                const SizedBox(width: 16),
                _iconButton('images/backtrack.png', size: 60, onTap: () async {
                  await profileController.restoreLastDislikedProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You restored the last disliked profile."),
                        backgroundColor: Colors.blueGrey,
                      ),
                    );
                  }
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter by Gender',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: const Text('All'),
                onTap: () {
                  ref.read(profileControllerProvider.notifier).setGenderFilter(null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Male'),
                onTap: () {
                  ref.read(profileControllerProvider.notifier).setGenderFilter('Male');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  ref.read(profileControllerProvider.notifier).setGenderFilter('Female');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
Widget _infoChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    margin: const EdgeInsets.only(right: 8, bottom: 8),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 248, 246, 246), // Light grey like in the image
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black12, // softer shadow
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(179, 10, 10, 10), // lighter text, not pure white
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}


  Widget _iconButton(String assetPath, {required VoidCallback onTap, double size = 65}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
