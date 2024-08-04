import 'package:flutter/material.dart';
import 'package:vita_seniors/screens/SplashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  initBackground();
  runApp(const MyApp());
}

void initBackground() async {
  await dotenv.load(fileName: ".env");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(85, 83, 202, 1)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(85, 83, 202, 1)),
        useMaterial3: true,
      ),
      home: const SplashScreenPage(),
    );
  }
}
