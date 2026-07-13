import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FinTrack', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Version 2.4.0'),
            SizedBox(height: 20),
            Text(
              'FinTrack helps you track income and expenses, stick to a monthly '
              'budget, and understand your spending with clear analytics — all '
              'stored privately on your device.',
            ),
          ],
        ),
      ),
    );
  }
}
