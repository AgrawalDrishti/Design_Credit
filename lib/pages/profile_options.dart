import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:design_credit/pages/create_profile.dart';
import 'package:design_credit/pages/audio_player.dart';
import 'package:design_credit/pages/navbar.dart';

class ProfileOptions extends StatefulWidget {
  const ProfileOptions({super.key});

  @override
  State<ProfileOptions> createState() => ProfileOptionsState();
}

class ProfileOptionsState extends State<ProfileOptions> {
  // late Directory _directory;
  // late List<String> _folderNames;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailIdController = TextEditingController();
  final genderController = TextEditingController();
  final fieldAController = TextEditingController();


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

    if (_folderNames.length == 0) {
      _selectedFolder = 'CreateNewProfile';
    } else {
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
                backgroundColor: Color(0xff1a1a26),
                  resizeToAvoidBottomInset: false,
                  // extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                  ),
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Text("Meditation App for AIIMS Rishikesh"),
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Profile Options'),
                          onTap: () {
                            Navigator.pop(context);
            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateProfile()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share Data'),
                          onTap: () {
                            // Navigator.pushNamed(context, '/audio_player');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete Data'),
                          onTap: () {
                            // Navigator.pushNamed(context, '/main_screen');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.code),
                          title: Text('Test Button'),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Enter Password"),
                                    content: TextField(
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                          hintText: "Enter Nurse Password"),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Submit"),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                  body: Container(
                    color: Color(0xff1a1a26),
                    child: Column(
                      children: [
                        Text(
                          "Profile Options",
                          style:
                              TextStyle(color: Color(0xff58c9b0), fontSize: 20),
                        ),
                        Text(
                          "Select existing profile ",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Container(
                          height: 40,
                          width: 140,
                          padding: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10)),
                          child: DropdownButton<String>(
                            // style: TextStyle(),
                            value: _selectedFolder,
                            items: snapshot.data!
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color:Colors.white),
                                ),
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
            
                        // create profile form
            
                        Column(
                          children: [
                            Container(
                              child: Text(
                                "Create a New Profile",
                                style: TextStyle(
                                    color: Color(0xff58c977), fontSize: 20),
                              ),
                            ),
                            
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20),
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.white),
                                            ),
                                            floatingLabelStyle:
                                                TextStyle(color: Colors.white),
                                            hintText: "Please enter your name",
                                            hintStyle:
                                                TextStyle(color: Colors.white38),
                                            labelText: "Name",
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .white), // For the label
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff58c9b0)),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter your name";
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20),
                                          controller: emailIdController,
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.white),
                                            ),
                                            hintText: "Please enter your age",
                                            hintStyle:
                                                TextStyle(color: Colors.white38),
                                            labelText: "Age",
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .white), // For the label
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff58c9b0)),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter your age";
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20),
                                          controller: genderController,
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.white),
                                            ),
                                            hintText: "Please enter your gender",
                                            hintStyle:
                                                TextStyle(color: Colors.white38),
                                            labelText: "Gender",
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .white), // For the label
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff58c9b0)),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter your gender";
                                            }
                                          },
                                        ),
                                        TextFormField(
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20),
                                          controller: fieldAController,
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.white),
                                            ),
                                            hintText:
                                                "Please enter your Nurse's name",
                                            hintStyle:
                                                TextStyle(color: Colors.white38),
                                            labelText: "Nurse Name",
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .white), // For the label
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff58c9b0)),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter your Nurse name";
                                            }
                                          },
                                        ),
                                        Padding(padding: EdgeInsets.all(10)),
                                        SizedBox(
                                          height: 50,
                                          width: 150,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xff58c9b0),
                                                textStyle:
                                                    TextStyle(fontSize: 18)),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                String folderName =
                                                    nameController.text;
                                                String folderPath =
                                                    await createFolder(
                                                        folderName,
                                                        nameController.text,
                                                        emailIdController.text,
                                                        genderController.text,
                                                        fieldAController.text);
            
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "Profile Created")));
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AudioPlayerPage(
                                                              selectedFolder:
                                                                  folderName)),
                                                );
                                              }
                                            },
                                            child: Text("Start"),
                                          ),
                                        ),
                                      ],
                                    ))),
                          ],
                        ),
                      ],
                    ),
                  ),
            );
          }
        });
  }

  @override
  void dispose() {
    _folderNamesStreamController.close();
    nameController.dispose();
    emailIdController.dispose();
    genderController.dispose();
    fieldAController.dispose();
    super.dispose();
  }
}
