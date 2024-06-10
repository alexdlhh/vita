import 'package:flutter/material.dart';
import 'package:vita_seniors/screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:const Color.fromRGBO(85, 83, 202, 1)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:const Color.fromRGBO(85, 83, 202, 1)),
        useMaterial3: true,
      ),
      home: const SplashScreenPage(),
    );
  }
}
