import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/splashScreen.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}