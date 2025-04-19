import 'package:flutter/material.dart';

class FavoriteSentFavoriteReceivedScreen extends StatefulWidget {
  const FavoriteSentFavoriteReceivedScreen({super.key});

  @override
  State<FavoriteSentFavoriteReceivedScreen> createState() => _FavoriteSentFavoriteReceivedScreenState();
}

class _FavoriteSentFavoriteReceivedScreenState extends State<FavoriteSentFavoriteReceivedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Chats',
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