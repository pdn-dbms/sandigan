import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/services/sqlite_db.dart';

class RVCount extends StatefulWidget {
  final String muni;
  final String brgy;
  RVCount({required this.muni, required this.brgy});

  @override
  _RVCountState createState() => _RVCountState();
}

class _RVCountState extends State<RVCount> {
  @override
  Widget build(BuildContext context) {
    var _stream = widget.brgy == ''
        ? SqliteDB().getMuniVLCount(muni: widget.muni)
        : SqliteDB().getBrgyVLCount(muni: widget.muni, brgy: widget.brgy);
    return FutureBuilder<Object>(
      future: _stream, // async work
      builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading....');
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var data = snapshot.data as Map;

              var percent = double.parse(data['supporters'].toString()) /
                  double.parse(data['voters'].toString());
              if (widget.brgy != '') {
                return Container(
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color: percent >= 0.5 ? Colors.blue : Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.brgy,
                          style: TextStyle(
                              color:
                                  percent >= 0.5 ? Colors.white : Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Voters: ${data['voters']} Supporters ${data['supporters']}',
                          style: TextStyle(
                              color:
                                  percent >= 0.5 ? Colors.white : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color: percent >= 0.5 ? Colors.blue : Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.muni,
                          style: TextStyle(
                              color:
                                  percent >= 0.5 ? Colors.white : Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Voters: ${data['voters']} Supporters ${data['supporters']}',
                          style: TextStyle(
                              color:
                                  percent >= 0.5 ? Colors.white : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                );
              }
            }
        }
      },
    );
  }
}
