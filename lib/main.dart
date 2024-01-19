import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';


void main() async {

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  print('Package Name: ${packageInfo.packageName}');

  WidgetsFlutterBinding.ensureInitialized();
   Map<Permission, PermissionStatus> statuses = await [
   Permission.storage,
 ].request();
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
      home: MainScreen(),
    );
  }
}