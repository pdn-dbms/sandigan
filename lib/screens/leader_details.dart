import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pol_dbms/model/leader_model.dart';
import 'package:pol_dbms/screens/access_editor_screen.dart';
import 'package:pol_dbms/services/db.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/lastknownlocation.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:pol_dbms/data/choices.dart' as choices;

class LeaderDetails extends StatefulWidget {
  final LeaderModel user;

  LeaderDetails({required this.user});
  @override
  State<LeaderDetails> createState() => _LeaderDetailsState();
}

_launchCaller(String number) async {
  String url = Platform.isIOS ? 'tel://$number' : 'tel:$number';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _LeaderDetailsState extends State<LeaderDetails> {
  bool isAdmin = false;
  bool isUserAdmin = false;
  @override
  void initState() {
    super.initState();
    updateAdminStatus();
  }

  void updateAdminStatus() {
    SqliteDB().getCurrentUserInfo().then((value) {
      var data = value as Map;
      setState(() {
        isAdmin = data['access']['type'] == 'admin';
        isUserAdmin = widget.user.access.type == 'admin';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.user;

    final SlidableController slidableController = SlidableController();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
      appBar: AppBar(
        title: Text(user.name),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Center(
                child: Column(
                  children: [
                    LastKnowLocation(
                        name: user.name,
                        lat: user.lastLocation.lat,
                        lng: user.lastLocation.lng),
                  ],
                ),
              )),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartSelect<String>.single(
                      title: 'Access Type',
                      selectedValue: widget.user.access.type,
                      onChange: (selected) {
                        Db().setUserType(user.uid, selected.value ?? 'user');
                        if (selected.value == 'user') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AcccessEditor(user: user)));
                        }
                        setState(() {
                          isUserAdmin =
                              selected.value == 'admin' ? true : false;
                        });
                      },
                      choiceItems: choices.userType,
                      modalType: S2ModalType.bottomSheet,
                      tileBuilder: (context, state) {
                        return S2Tile.fromState(
                          state,
                          isTwoLine: true,
                        );
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Contact Info",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                        itemCount: user.contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final contact = user.contacts[index];

                          return Slidable(
                            controller: slidableController,
                            actionExtentRatio: 0.25,
                            actionPane: SlidableDrawerActionPane(),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  caption: 'Call',
                                  color: Colors.blue,
                                  icon: Icons.phone,
                                  onTap: () {
                                    _launchCaller(contact.toString());
                                  }),
                              IconSlideAction(
                                caption: 'SMS',
                                color: Colors.indigo,
                                icon: Icons.sms_outlined,
                                onTap: () => UrlLauncher.launch(
                                    "sms:" + contact.toString()),
                              ),
                              IconSlideAction(
                                caption: 'Update',
                                color: Colors.green,
                                icon: Icons.edit,
                              ),
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete_outline,
                                onTap: () => {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: Text("Confirm deletion!"),
                                            content: Text(
                                                "Are you sure you want to delete $contact?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text("Close"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Confirm"),
                                                onPressed: () {
                                                  // FirebaseFirestore.instance
                                                  //     .collection('municipalities')
                                                  //     .doc(widget.municipality.id)
                                                  //     .collection('barangay')
                                                  //     .doc(widget.barangay)
                                                  //     .collection('officials')
                                                  //     .doc(officials[index]['id'])
                                                  //     .delete();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ]);
                                      })
                                },
                              ),
                            ],
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(user.contacts[index],
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  Divider()
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  isAdmin && !isUserAdmin
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AcccessEditor(user: user)));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: const Offset(2, 4),
                                      blurRadius: 5,
                                      spreadRadius: 2)
                                ],
                                gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Colors.blueAccent, Colors.blue])),
                            child: Text(
                              'Limit Access',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
