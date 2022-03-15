import 'package:flutter/material.dart';
import 'package:pol_dbms/screens/create_user.dart';
import 'package:pol_dbms/widgets/leaders.dart';
import 'package:pol_dbms/widgets/project_list.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Projects'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Register()));
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Container(
                margin: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30.0))),
                child: ProjectList()),
          )
        ]));
  }
}
