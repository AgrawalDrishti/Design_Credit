import 'dart:async';
import 'dart:io';
import 'package:design_credit/main_screen.dart';
import 'package:design_credit/pages/profile_options.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:design_credit/pages/create_profile.dart';
import 'package:design_credit/pages/audio_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds:  3) , () async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? existingUser = prefs.getString('selectedFolder');

      if (existingUser != null && existingUser.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AudioPlayerPage(selectedFolder: existingUser)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateProfile()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff1A1A26),
        child: Image(image: AssetImage('images/aiimsLogo.png')),
        height: MediaQuery.of(context).size.height ,
      ),
    );
  }
}
