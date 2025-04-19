// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ua_dating_app/controllers/profile_controller.dart';

class SwipingScreen extends StatefulWidget {
  const SwipingScreen({super.key});

  @override
  State<SwipingScreen> createState() => _SwipingScreenState();
}

class _SwipingScreenState extends State<SwipingScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (profileController.allUsersProfileList.isEmpty) {
          return const Center(child: Text("No profiles found."));
        }

        return PageView.builder(
          itemCount: profileController.allUsersProfileList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final eachProfileInfo = profileController.allUsersProfileList[index];

            return GestureDetector(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(eachProfileInfo.imageProfile ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        eachProfileInfo.name ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${eachProfileInfo.age} • ${eachProfileInfo.city ?? 'Unknown'}",
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
                          if ((eachProfileInfo.courseOrStrand ?? '').isNotEmpty)
                            _infoChip(eachProfileInfo.courseOrStrand!),
                          const SizedBox(width: 8),
                          if ((eachProfileInfo.lookingForInaPartner ?? '').isNotEmpty)
                            _infoChip(eachProfileInfo.lookingForInaPartner!),
                        ],
                      ),
                      const SizedBox(height: 32),

                      /// Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _iconButton('images/back.png', onTap: () {
                            // Optional: handle skip/back
                          }),

                          _iconButton('images/fav.png', onTap: () {
                            // Optional: handle favorite
                          }),

                          _iconButton('images/like.png', onTap: () {
                            profileController.likeSentAndLikeReceived(
                              eachProfileInfo.uid ?? '',
                              eachProfileInfo.name ?? 'Unknown',
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("You liked ${eachProfileInfo.name}"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
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
