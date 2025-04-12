import 'package:flutter/material.dart';
import 'package:onfit/homescreen.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // scaffoldBackgroundColor: Colors.white.withOpacity(0.2)
        ),
      home: HomeScreen(),
    );
  }
}