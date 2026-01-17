import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'This is the Account Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}