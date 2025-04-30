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

    if (profiles.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("No profiles found.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
            Expanded(
              child: Center(
                child: TinderSwapCard(
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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              profile.imageProfile ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.error)),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  profile.name ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${profile.age} • ${profile.city ?? 'Unknown'}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if ((profile.lookingForInaPartner ?? '').isNotEmpty)
                                      _infoChip(profile.lookingForInaPartner!),
                                    const SizedBox(width: 8),
                                    if ((profile.selectedGender ?? '').isNotEmpty)
                                      _infoChip(profile.selectedGender!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("You liked ${swipedProfile.name}"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } else if (orientation == CardSwipeOrientation.left) {
                      await profileController.dislikeUser(swipedProfile.uid ?? '');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You disliked ${swipedProfile.name}"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconButton('images/back.png', size: 60, onTap: () async {
                  final profile = profiles[0];
                  await profileController.dislikeUser(profile.uid ?? '');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You disliked ${profile.name}"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }),
                const SizedBox(width: 16),
                _iconButton('images/like.png', size: 90, onTap: () async {
                  final profile = profiles[0];
                  final alreadyLiked = await profileController
                      .isAlreadyLiked(profile.uid ?? '');

                  if (!alreadyLiked) {
                    await profileController.likeSentAndLikeReceived(
                      profile.uid ?? '',
                      profile.name ?? 'Unknown',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You liked ${profile.name}"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You already liked this user."),
                          backgroundColor: Colors.blueGrey,
                        ),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _iconButton(String assetPath,
      {required VoidCallback onTap, double size = 65}) {
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
