import 'package:flutter/material.dart';

class SocialAppScreen extends StatelessWidget {
  final String appName;
  const SocialAppScreen({Key? key, required this.appName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Welcome to $appName',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
