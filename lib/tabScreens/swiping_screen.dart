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
          return const Center(
            child: Text("No profiles found."),
          );
        }

        return PageView.builder(
          itemCount: profileController.allUsersProfileList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final eachProfileInfo = profileController.allUsersProfileList[index];

            return DecoratedBox(
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
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  eachProfileInfo.name ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
