import 'package:flutter/material.dart';
import 'package:ua_dating_app/models/person.dart';

class ProfileCard extends StatelessWidget {
  final Person profile;
  final VoidCallback onClose;

  const ProfileCard({super.key, required this.profile, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(24),
        elevation: 30,
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          child: Image.network(
                            profile.imageProfile ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.error, color: Colors.white)),
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
                          "${profile.age ?? '??'} • ${profile.courseOrStrand ?? 'Unknown'}",
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
                    if ((profile.city ?? '').trim().isNotEmpty) ...[
                      const Text(
                        "My Location",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 68, 68, 68),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
    profile.city!,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold, // or FontWeight.bold
      color: Colors.black,
    ),
    textAlign: TextAlign.start,
  ),

                      const SizedBox(height: 24),
                    ],

                  ],
                ),
              ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  static Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 246, 246), // Light grey color for visibility
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Subtle shadow for better contrast
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(179, 10, 10, 10), // Darker text for contrast
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
