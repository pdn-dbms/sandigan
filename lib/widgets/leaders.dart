import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pol_dbms/model/leader_model.dart';
import 'package:pol_dbms/model/municipality_model.dart';
import 'package:pol_dbms/screens/leader_details.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Leaders extends StatefulWidget {
  @override
  _LeaderState createState() => _LeaderState();
}

class _LeaderState extends State<Leaders> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('leaders')
            .orderBy('name')
            .snapshots(),
        builder:
            (BuildContext buildContext, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          List<Map<String, dynamic>> leaders = [];

          snapshot.data!.docs.forEach((doc) {
            Map data = doc.data() as Map;
            if (doc.id != uid) {
              leaders.add({
                'id': doc.id,
                'name': data['name'],
                'contacts': data['contacts'],
                'access': data['access'],
                'app_access': data['app_access'],
                'last_location': data['last_location']
              });
            }
          });
          final SlidableController slidableController = SlidableController();
          return ListView.builder(
              itemCount: leaders.length,
              itemBuilder: (BuildContext context, int index) {
                final _data = leaders[index];

                final lat = _data['last_location'].latitude.toString();
                final lng = _data['last_location'].longitude.toString();

                final name = (_data as dynamic)['name'].toString();
                final isValid = (_data as dynamic)['contacts'].length > 0
                    ? validateMobile(
                        (_data as dynamic)['contacts'][0].toString())
                    : false;

                return Slidable(
                  controller: slidableController,
                  actionExtentRatio: isValid ? 0.2 : 0.30,
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    if (isValid == true)
                      IconSlideAction(
                          caption: 'Call',
                          color: Colors.blue,
                          icon: Icons.phone,
                          onTap: () => UrlLauncher.launch("tel://" +
                              (_data as dynamic)['contacts'][0].toString())),
                    if (isValid == true)
                      IconSlideAction(
                        caption: 'SMS',
                        color: Colors.indigo,
                        icon: Icons.sms_outlined,
                        onTap: () => UrlLauncher.launch("sms:" +
                            (_data as dynamic)['contacts'][0].toString()),
                      ),
                    IconSlideAction(
                      caption: 'Locate',
                      color: Colors.orange,
                      icon: Icons.location_on_rounded,
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
                                      "Are you sure you want to delete $name information?"),
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
                  child: GestureDetector(
                    onTap: () {
                      final String json = '{"lat": ' +
                          _data['last_location'].latitude.toString() +
                          ', "lng":' +
                          _data['last_location'].longitude.toString() +
                          '}';
                      final LeaderModel model = LeaderModel(
                          uid: _data['id'],
                          access: Access.fromJson(_data['access']),
                          name: _data['name'],
                          contacts: List.from(_data['contacts']),
                          lastLocation:
                              LastLocation.fromJson(jsonDecode(json)));

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LeaderDetails(user: model)));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold)),
                          Text((_data as dynamic)['access']['type'].toString(),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal)),
                          Divider()
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }

  bool validateMobile(String value) {
    value = value.replaceAll('-', '');
    value = value.replaceAll(' ', '');
    if (value.length == 10) value = '0' + value;
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }
}
