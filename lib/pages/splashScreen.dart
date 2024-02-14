import 'dart:async';
import 'dart:io';
import 'package:design_credit/main_screen.dart';
import 'package:design_credit/pages/profile_options.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:design_credit/pages/create_profile.dart';
import 'package:design_credit/pages/audio_player.dart';
import 'package:path_provider/path_provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String _selectedFolder;
  StreamController<List<String>> _folderNamesStreamController =
      StreamController<List<String>>();

  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds:  3) , (){
      _fetchFolderNames().then((isEmpty) {
        if(isEmpty){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CreateProfile()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      });
    });
  }

  Future<bool> _fetchFolderNames() async {
    final directoryPath = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    Directory _directory = Directory(directoryPath!.path);
    print(_directory);
    List<String> _folderNames = _directory
        .listSync()
        .map((entity) => path.basename(entity.path))
        .toList();
    _folderNamesStreamController.add(_folderNames);
    print(_folderNames);
    return _folderNames.isEmpty;
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
