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
                                  builder: (context) => CreateProfile()),
                            );
                          },
                          child: Text("Show Profiles", style: TextStyle(color: Colors.white, fontSize: 13),),

                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black45),
                              
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
                              MaterialPageRoute(
                                  builder: (context) => CreateProfile()),
                            );
                          },
                          child: Text("Create Profile", style: TextStyle(color: Colors.white, fontSize: 13),),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
