import 'package:flutter/material.dart';

class LikeSentLikeReceivedScreem extends StatefulWidget {
  const LikeSentLikeReceivedScreem({super.key});

  @override
  State<LikeSentLikeReceivedScreem> createState() => _LikeSentLikeReceivedScreemState();
}

class _LikeSentLikeReceivedScreemState extends State<LikeSentLikeReceivedScreem> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Swiping Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}