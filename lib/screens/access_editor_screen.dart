import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/model/leader_model.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/multisheet.dart';

class AcccessEditor extends StatefulWidget {
  final LeaderModel user;

  const AcccessEditor({required this.user});

  @override
  State<AcccessEditor> createState() => _AcccessEditorState();
}

class _AcccessEditorState extends State<AcccessEditor> {
  List<dynamic> lgus = [];

  get name => null;

  @override
  void initState() {
    super.initState();
    SqliteDB().getLGU().then((data) {
      setState(() {
        lgus = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
        appBar: AppBar(
          title: Text(widget.user.name + '\'s Access'),
          centerTitle: true,
        ),
        body: Column(
          children: [FeaturesMultiSheet(uid: widget.user.uid)],
        ));
  }
}
