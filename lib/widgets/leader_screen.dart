import 'package:flutter/material.dart';
import 'package:pol_dbms/screens/create_user.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/leaders.dart';

class LeaderScreen extends StatefulWidget {
  @override
  _LeaderScreenState createState() => _LeaderScreenState();
}

class _LeaderScreenState extends State<LeaderScreen> {
  bool isAdmin = true;
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
    return Scaffold(
        backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
        appBar: AppBar(
          title: Text('Leaders'),
          centerTitle: true,
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Register()));
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.blue,
              )
            : Container(),
        body: Column(children: <Widget>[
          Expanded(
            child: Container(
                margin: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30.0))),
                child: Leaders()),
          )
        ]));
  }
}
