import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coming Soon'),
      ),
      body: const Center(
        child: Text(
          'This feature is coming soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}