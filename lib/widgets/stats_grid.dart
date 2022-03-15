import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatGrid extends StatefulWidget {
  @override
  _StatGridState createState() => _StatGridState();
}

class _StatGridState extends State<StatGrid> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('global_value')
            .doc('dashboard')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          late String sup = '0',
              proj = '0',
              leaders = '0',
              assist = '0',
              reports = '0',
              voters = '0';

          var data = snapshot.data;

          sup = data!['supporters'].toString();
          proj = data['projects'].toString();
          leaders = data['leaders'].toString();
          assist = data['assistance'].toString();
          reports = data['reports_new'].toString() +
              '/' +
              data['reports_resolved'].toString();
          voters = data['voters_count'].toString();

          return Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCard('Voters', voters, Colors.amber),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCard('Supporters', sup, Colors.blue),
                      _buildStatCard('Projects', proj, Colors.red),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      _buildStatCard('Leaders', leaders, Colors.green),
                      _buildStatCard('Assistance', assist, Colors.lightGreen),
                      _buildStatCard('Reports', reports, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Expanded _buildStatCard(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
