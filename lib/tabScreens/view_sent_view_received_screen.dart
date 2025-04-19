import'package:flutter/material.dart';

class ViewSentViewReceivedScreen extends StatefulWidget {
  const ViewSentViewReceivedScreen({super.key});

  @override
  State<ViewSentViewReceivedScreen> createState() => _ViewSentViewReceivedScreenState();
}

class _ViewSentViewReceivedScreenState extends State<ViewSentViewReceivedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'View Sent View Received Screen',
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