import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/home_screen.dart';
import 'package:pol_dbms/login.dart';
import 'package:pol_dbms/services/db.dart';
import 'package:pol_dbms/services/sqlite_db.dart';

import 'model/voter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(App());
}

Future getCurrentUser() async {
  User _user = FirebaseAuth.instance.currentUser!;

  Db().getUserAccess(_user.uid).then((value) {
    var data = value.data() as Map;
    data.remove('last_location');
    SqliteDB().updateLocalConfig('user', json.encode(data));
  });

  return _user;
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final ThemeData theme = ThemeData();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDN-DBMS',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
            secondary: const Color(0XFFF9EFEB),
            primary: const Color(0x09251000)),
      ),
      home: FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoginPage();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data == null ? LoginPage() : HomeScreen();
          }
          return LoginPage();
        },
      ),
    );
  }
}
