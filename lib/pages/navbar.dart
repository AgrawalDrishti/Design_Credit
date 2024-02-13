import 'package:flutter/material.dart';

class HamBurgerMenu extends StatelessWidget {
  const HamBurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Create Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/create_profile');
            },
          ),
          ListTile(
            title: Text('Audio Player'),
            onTap: () {
              Navigator.pushNamed(context, '/audio_player');
            },
          ),
          ListTile(
            title: Text('Main Screen'),
            onTap: () {
              Navigator.pushNamed(context, '/main_screen');
            },
          ),
        ],
      ),
    );
  }
}
