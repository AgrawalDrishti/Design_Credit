import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:design_credit/pages/create_profile.dart';
import 'package:design_credit/pages/audio_player.dart';
import 'package:path_provider/path_provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // late Directory _directory;
  // late List<String> _folderNames;
  late String _selectedFolder;
  StreamController<List<String>> _folderNamesStreamController =
      StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    _fetchFolderNames();
  }

  Future<void> _fetchFolderNames() async {
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

    if(_folderNames.length == 0){
      _selectedFolder = 'CreateNewProfile';
    }else{
      _selectedFolder = _folderNames[0];
    }
    print(_selectedFolder);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
        // future: _fetchFolderNames(),
        stream: _folderNamesStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                // appBar: AppBar(
                //   backgroundColor: Colors.black87,
                //   title: Text("Demo App"),
                //   centerTitle: true,
                //   titleTextStyle: TextStyle(
                //       color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                // ),
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/kt3.jpg'),
                        fit: BoxFit.fill,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5), BlendMode.dstATop)),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(padding: EdgeInsets.all(25)),
                          Center(
                              child: Column(
                            children: [
                              Image(
                                image: AssetImage('images/Logo.png'),
                                height: 200,
                              )
                            ],
                          ))
                        ],
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AudioPlayerPage(
                                              selectedFolder: _selectedFolder)),
                                    );
                                  },
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black45),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 140,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CreateProfile()),
                                        );
                                      },
                                      child: Text(
                                        "Create Profile",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black45),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 10)),
                                  Container(
                                    height: 40,
                                    width: 140,
                                    padding: EdgeInsets.only(left: 5),

                                    decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: DropdownButton<String>(
                                      // style: TextStyle(),
                                      value: _selectedFolder,
                                      items: snapshot.data!
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value , textAlign: TextAlign.center,),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedFolder = newValue!;
                                        });
                                        // setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          }
        });
  }

  @override
  void dispose() {
    _folderNamesStreamController.close();
    super.dispose();
  }
}
