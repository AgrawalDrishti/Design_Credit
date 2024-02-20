import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:design_credit/pages/audio_player.dart';

// Future<String> createFolder(String folderName, String name, String emailId , String gender, String fieldA) async {
//   print("Entered Function");
//  final dir = Directory((Platform.isAndroid
//     ? await getExternalStorageDirectory()
//     : await getApplicationSupportDirectory())!
//     .path + '/$folderName');
//  var status = await Permission.storage.status;
//  if (!status.isGranted) {
//   await Permission.storage.request();
//  }
//
//   print(dir.path);
//  if ((await dir.exists())) {
//    print(dir.path);
//   return dir.path;
//  } else {
//   dir.create();
//
//   final file = File('${dir.path}/profile.json');
//   final profileData = {
//     'name': name,
//     'email': emailId,
//     'gender': gender,
//     'fieldA': fieldA,
//   };
//   file.writeAsStringSync(jsonEncode(profileData));
//  return dir.path;
//  }
//
// }

Future<String> createFolder(
    String folderName, String name, String emailId, String gender, String fieldA) async {
  // 1. Check if we can get broad external storage access (Android 11+)
  bool hasBroadAccess = await _manageExternalStoragePermission();

  Directory? dir;

  if (hasBroadAccess) {
    // Ideal if broad access is granted
    dir = await getExternalStorageDirectory();
  } else {
    // No broad access? Use app-specific storage
    dir = await getApplicationDocumentsDirectory();
  }

  // Create your subfolder within the chosen directory
  final subDir = Directory('${dir!.path}/$folderName');
  if (await subDir.exists()) {
    // File writing logic if the subfolder already exists
    final file = File('${subDir.path}/profile.json');
    final profileData = {
      'name': name,
      'email': emailId,
      'gender': gender,
      'fieldA': fieldA,
    };
    file.writeAsStringSync(jsonEncode(profileData));

    return subDir.path;
  } else {
    await subDir.create();

    // File writing logic after creating the subfolder
    final file = File('${subDir.path}/profile.json');
    final profileData = {
      'name': name,
      'email': emailId,
      'gender': gender,
      'fieldA': fieldA,
    };
    file.writeAsStringSync(jsonEncode(profileData));

    return subDir.path;
  }
}


// Helper function for requesting storage permissions
Future<bool> _manageExternalStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else {
      return await Permission.storage.request().isGranted;
    }
  } else {
    // Permissions aren't a concern on other platforms
    return true;
  }
}





class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<StatefulWidget> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailIdController = TextEditingController();
  final genderController = TextEditingController();
  final fieldAController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailIdController.dispose();
    genderController.dispose();
    fieldAController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff1a1a26),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Text(
                  "Create a New Profile",
                  style: TextStyle(color: Color(0xff58c977), fontSize: 30),
                ),
              ),
              Lottie.asset(
                'jsons/welcome.json',
                animate: true,
                height: 250
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                            ),
                            controller: nameController,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.white), ),
                              floatingLabelStyle: TextStyle(color: Colors.white),
                              hintText: "Please enter your name",
                              hintStyle: TextStyle(color: Colors.white38),
                              labelText: "Name",
                              labelStyle:
                                  TextStyle(color: Colors.white), // For the label
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff58c9b0)),
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
                              color: Colors.white,
                              fontSize: 20
                            ),
                            controller: emailIdController,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.white), ),
                              hintText: "Please enter your age",
                              hintStyle: TextStyle(color: Colors.white38),
                              labelText: "Age",
                              labelStyle:
                                  TextStyle(color: Colors.white), // For the label
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff58c9b0)),
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
                              color: Colors.white,
                              fontSize: 20
                            ),
                            controller: genderController,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.white), ),
                              hintText: "Please enter your gender",
                              hintStyle: TextStyle(color: Colors.white38),
                              labelText: "Gender",
                              labelStyle:
                                  TextStyle(color: Colors.white), // For the label
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff58c9b0)),
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
                              color: Colors.white,
                              fontSize: 20
                            ),
                            controller: fieldAController,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(borderSide:BorderSide(color: Colors.white), ),
                              hintText: "Please enter your Nurse's name",
                              hintStyle: TextStyle(color: Colors.white38),
                              labelText: "Nurse Name",
                              labelStyle:
                                  TextStyle(color: Colors.white), // For the label
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff58c9b0)),
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
                              
                                  backgroundColor: Color(0xff58c9b0),
                                  textStyle: TextStyle(fontSize: 18)),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  String folderName = nameController.text;
                                  String folderPath = await createFolder(
                                      folderName,
                                      nameController.text,
                                      emailIdController.text,
                                      genderController.text,
                                      fieldAController.text);
                          
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Profile Created")));
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => AudioPlayerPage(
                                            selectedFolder: folderName)),
                                  );
                                }
                              },
                              child: Text("Create Profile" ,textAlign: TextAlign.center , style: TextStyle(fontSize: 14),),
                            ),
                          ),
                        ],
                      )
                      
                      )
                      ),
            ],
          ),
        
        ));
  }
}
