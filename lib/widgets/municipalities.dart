import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:pol_dbms/model/municipality_model.dart';
import 'package:pol_dbms/model/user_access.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/municipality_screen.dart';
import 'package:pol_dbms/widgets/rv_count.dart';
import 'package:collection/collection.dart';

class Municipalities extends StatefulWidget {
  Municipalities({Key? key}) : super(key: key);

  @override
  _MunicipalitiesState createState() => _MunicipalitiesState();
}

Future<String> getJson() {
  return rootBundle.loadString('assets/data.json');
}

class _MunicipalitiesState extends State<Municipalities> {
  bool isAdmin = false;
  List<UserAccess> userAccess = [];
  List<dynamic> municipalities = [];
  @override
  void initState() {
    super.initState();
    SqliteDB().getCurrentUserInfo().then((value) {
      var data = value as Map;

      setState(() {
        userAccess = List.generate(data['app_access'].length, (i) {
          var _raw = data['app_access'][i] as Map;
          return UserAccess(
              name: _raw['name'], access: List.from(_raw['access']));
        });

        rootBundle.loadString('assets/data.json').then((municipality) {
          var muni = json.decode(municipality);

          if (!isAdmin) {
            for (var i = 0; i < muni.length; i++) {
              final access = userAccess.firstWhereOrNull(
                  (element) => muni[i]['value'].toUpperCase() == element.name);

              if (access != null) {
                municipalities.add(muni[i]);
              }
            }
          } else {
            municipalities = List.from(muni);
          }

          municipalities.sort((a, b) => a['order'].compareTo(b['order']));
        });
        isAdmin = data['access']['type'] == 'admin';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: municipalities.length,
        itemBuilder: (BuildContext context, int index) {
          final String muni = municipalities[index]['code'];
          final List<String> barangay =
              List.from(municipalities[index]['barangay']);
          final Municipality municipality = Municipality(
              id: municipalities[index]['code'],
              name: municipalities[index]['value'],
              barangay: barangay);
          return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          MunicipalityScreen(municipality: municipality))),
              child: RVCount(
                  muni: municipalities[index]['value'].toString().toUpperCase(),
                  brgy: ''));
        });
  }
}
