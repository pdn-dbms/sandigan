import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Province extends StatefulWidget {
  const Province({Key? key}) : super(key: key);

  @override
  _ProvinceState createState() => _ProvinceState();
}

class _ProvinceState extends State<Province> {
  final List<String> positions = ['GOVERNOR', 'VICE GOVERNOR', 'BOARD MEMBER'];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('province')
            .orderBy('name')
            .snapshots(),
        builder:
            (BuildContext buildContext, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          List<Map<String, dynamic>> officials = [];

          snapshot.data!.docs.forEach((doc) {
            Map data = doc.data() as Map;
            officials.add({
              'id': doc.id,
              'name': data['name'],
              'contact': [data['contact']],
              'position': data['position'],
              'order': data['position'] == 'GOVERNOR'
                  ? 1
                  : data['position'] == 'VICE-GOVERNOR'
                      ? 2
                      : 3
            });
            officials.sort((a, b) => a['order'].compareTo(b['order']));
          });
          final SlidableController slidableController = SlidableController();
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                final _data = officials[index];

                final name = (_data as dynamic)['name'].toString();
                final isValid =
                    validateMobile((_data as dynamic)['contact'][0].toString());

                return Slidable(
                  controller: slidableController,
                  actionExtentRatio: isValid == true ? 0.25 : 0.50,
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    if (isValid == true)
                      IconSlideAction(
                          caption: 'Call',
                          color: Colors.blue,
                          icon: Icons.phone,
                          onTap: () => UrlLauncher.launch("tel://" +
                              (_data as dynamic)['contact'][0].toString())),
                    if (isValid == true)
                      IconSlideAction(
                        caption: 'SMS',
                        color: Colors.indigo,
                        icon: Icons.sms_outlined,
                        onTap: () => UrlLauncher.launch("sms:" +
                            (_data as dynamic)['contact'][0].toString()),
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
                                        FirebaseFirestore.instance
                                            .collection('province')
                                            .doc(officials[index]['id'])
                                            .delete();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ]);
                            })
                      },
                    ),
                  ],
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Text((_data as dynamic)['position'].toString(),
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal)),
                        Divider()
                      ],
                    ),
                  ),
                );
              });
        });
  }

  bool validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
    ;
  }
}
