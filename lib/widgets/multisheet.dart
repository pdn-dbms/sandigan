import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:pol_dbms/model/user_access.dart';
import 'package:pol_dbms/services/db.dart';
import 'package:pol_dbms/services/sqlite_db.dart';

class FeaturesMultiSheet extends StatefulWidget {
  final String uid;
  FeaturesMultiSheet({required this.uid});

  @override
  _FeaturesMultiSheetState createState() => _FeaturesMultiSheetState();
}

class _FeaturesMultiSheetState extends State<FeaturesMultiSheet> {
  List<dynamic> _userAccess = [];

  List<S2Choice<String>> _brgyBuilder(brgy) {
    List<S2Choice<String>> _brgy = [];
    _brgy.add(S2Choice(title: 'All', value: 'All'));
    for (int i = 0; i < brgy.length; i++) {
      _brgy.add(S2Choice(title: brgy[i], value: brgy[i]));
    }
    return _brgy;
  }

  @override
  void initState() {
    super.initState();

    Db().getUserAccess(widget.uid).then((value) {
      setState(() {
        var data = value.data() as Map;

        var theItems = data['app_access'].map((i) {
          var z = Map<String, dynamic>.from(i);
          return UserAccess.fromMap(z);
        }).toList();
        _userAccess = List<UserAccess>.from(theItems);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.amberAccent,
              semanticsLabel: 'Getting LGU data...',
              strokeWidth: 4.0,
            ));
          } else {
            var lgus = snapshot.data;

            getValue(name, index) {
              var res = _userAccess
                  .firstWhere((element) => element.name == name, orElse: () {
                return UserAccess(name: name, access: []);
              });
              return res.access;
            }

            return Expanded(
                child: ListView.builder(
                    itemCount: lgus.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                          color: Colors.white,
                          child: SmartSelect<String>.multiple(
                              title: lgus[index]['name'],
                              selectedValue:
                                  getValue(lgus[index]['name'], index),
                              onChange: (selected) {
                                final _entry = _userAccess.firstWhereOrNull(
                                    (element) =>
                                        element.name == lgus[index]['name']);
                                selected?.value?.contains('All');
                                if (_entry == null) {
                                  _userAccess.add(UserAccess(
                                      name: lgus[index]['name'],
                                      access:
                                          selected?.value?.contains('All') ==
                                                  true
                                              ? ['All']
                                              : selected?.value));
                                } else {
                                  _userAccess.remove(_entry);
                                  _userAccess.add(UserAccess(
                                      name: lgus[index]['name'],
                                      access:
                                          selected?.value?.contains('All') ==
                                                  true
                                              ? ['All']
                                              : selected?.value));
                                }
                                var toRemove = [];
                                _userAccess.forEach((entry) => {
                                      if (entry.access == null)
                                        toRemove.add(entry)
                                    });

                                _userAccess
                                    .removeWhere((e) => toRemove.contains(e));

                                Db().updateAccess(
                                    widget.uid, json.encode(_userAccess));
                              },
                              choiceItems: _brgyBuilder(lgus[index]['brgy']),
                              modalType: S2ModalType.bottomSheet,
                              tileBuilder: (context, state) {
                                return S2Tile.fromState(
                                  state,
                                  isTwoLine: true,
                                );
                              }));
                    }));
          }
        },
        future: SqliteDB().getLGU());
  }
}
