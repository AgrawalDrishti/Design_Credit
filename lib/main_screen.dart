import 'package:flutter/material.dart';
import 'package:design_credit/pages/create_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Demo App"),
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(10)),
          Center(
              child: Column(
            children: [
              Container(
                child: Image(
                  image: AssetImage('images/IITJ.jpg'),
                  height: 120,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Container(
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
                            MaterialPageRoute(builder: (context) => CreateProfile()),
                          );
                        },
                        child: Text("Show Profiles"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400]),
                      ),
                    ),

                    Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),

                    SizedBox(
                      height: 40,
                      width: 140,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateProfile()),
                          );
                          }, 
                          child: Text("Create Profiles"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400]),
                          ),
                          
                    ),
                    // ElevatedButton(onPressed: (){}, child: Text("Create Profile")),
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
