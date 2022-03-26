import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/login.dart';
import 'package:pol_dbms/model/voter.dart';
import 'package:pol_dbms/screens/project_screen.dart';
import 'package:pol_dbms/screens/stats_screen.dart';
import 'package:pol_dbms/services/auth.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/leader_screen.dart';
import 'package:pol_dbms/widgets/leaders.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  final String name = FirebaseAuth.instance.currentUser!.displayName.toString();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    SqliteDB().getCurrentUserInfo().then((value) {
      var data = value as Map;

      setState(() {
        isAdmin = data['access']['type'] == 'admin';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              "Hi " + name,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_customize_rounded),
            title: Text('Dashboard'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => StatsScreen()))
            },
          ),
          isAdmin
              ? ListTile(
                  leading: Icon(Icons.people_alt_outlined),
                  title: Text('Leaders'),
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LeaderScreen()))
                  },
                )
              : Container(),

          // ListTile(
          //   leading: Icon(Icons.verified_user),
          //   title: Text('Assistance'),
          //   onTap: () => {Navigator.of(context).pop()},
          // ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Projects'),
          //   onTap: () => {
          //     Navigator.push(
          //         context, MaterialPageRoute(builder: (_) => ProjectScreen()))
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {
              FireAuth.signOut().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage())))
            },
          ),
        ],
      ),
    );
  }
}
