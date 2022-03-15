import 'package:flutter/material.dart';
import 'package:pol_dbms/model/brgy.dart';
import 'package:pol_dbms/model/municipality_model.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/barangay_screen.dart';
import 'package:pol_dbms/widgets/rv_count.dart';

class BarangayList extends StatelessWidget {
  final Municipality municipality;
  BarangayList({required this.municipality});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Brgy>>(
      future: SqliteDB().getBarangay(muni: municipality.name),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: const CircularProgressIndicator());
        }

        return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BarangayScreen(
                            barangay: snapshot.data[index].name,
                            municipality: municipality))),
                child: Container(
                  margin: EdgeInsets.all(0.0),
                  child: RVCount(
                      muni: municipality.name, brgy: snapshot.data[index].name),
                ),
              );
            });
      },
    );
  }
}
