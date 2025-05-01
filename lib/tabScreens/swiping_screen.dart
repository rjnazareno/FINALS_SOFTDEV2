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
