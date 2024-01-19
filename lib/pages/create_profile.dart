import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<String> createFolder(String folderName) async {
 final dir = Directory((Platform.isAndroid
     ? await getExternalStorageDirectory()
     : await getApplicationSupportDirectory())!
     .path + '/$folderName');
 var status = await Permission.storage.status;
 if (!status.isGranted) {
   await Permission.storage.request();
 }
 if ((await dir.exists())) {
   return dir.path;
 } else {
   dir.create();
   return dir.path;
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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Create A New Profile"),),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: "Name"),
              validator: (value){
                if (value!.trim().isEmpty) {
                  return "Please enter your name";
                }
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "EmailID"),
              validator: (value){
                if (value!.trim().isEmpty) {
                  return "Please enter your Email ID";
                }
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Gender"),
              validator: (value){
                if (value!.trim().isEmpty) {
                  return "Please enter your gender";
                }
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "FieldA"),
              validator: (value){
                if (value!.trim().isEmpty) {
                  return "Please enter the FieldA";
                }
              },
            ),

            ElevatedButton(
              onPressed: (){
                if(formKey.currentState!.validate()){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Created")));
                }
              },
              child: Text("Create Profile"),
            )
          ]))
        )
    );
  }
}
