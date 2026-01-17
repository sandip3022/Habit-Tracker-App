import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'This is the Progress Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}