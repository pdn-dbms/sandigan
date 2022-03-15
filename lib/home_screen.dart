import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/config/styles.dart';
import 'package:pol_dbms/model/voter.dart';
import 'package:pol_dbms/services/db.dart';
import 'package:pol_dbms/services/geolocator.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/municipalities.dart';
import 'package:pol_dbms/widgets/navigation_bar.dart';
import 'package:pol_dbms/widgets/palawan_map.dart';
import 'package:pol_dbms/widgets/province.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var initIndex = 0;
  int currentIndex = 0;
  bool isSync = false;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    AppGeoLocator.determinePosition().then((result) {
      User? user = FirebaseAuth.instance.currentUser;
      Db().updateUserLocation(user!.uid, result.latitude, result.longitude);
    });
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        drawer: NavDrawer(),
        backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
        appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(Icons.menu),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () {
                  _key.currentState!.openDrawer();
                }),
            title: const Text('Sandigan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
            elevation: 0.0,
            actions: <Widget>[
              Visibility(
                visible: !isSync,
                child: IconButton(
                    icon: const Icon(Icons.sync_alt_rounded),
                    iconSize: 30.0,
                    color: Colors.white,
                    onPressed: () {
                      showAlertDialog(context);
                    }),
              )
            ]),
        body: Column(children: <Widget>[
          DefaultTabController(
            length: 3,
            initialIndex: initIndex,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.transparent),
              child: TabBar(
                controller: _tabController,
                indicator: const BubbleTabIndicator(
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  indicatorHeight: 45.0,
                  indicatorColor: Colors.white,
                ),
                labelStyle: Styles.tabTextStyle,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white60,
                tabs: const <Widget>[
                  Text('Map',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.0)),
                  Text('Officials',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.0)),
                  Text('Municipalities',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.0)),
                ],
                onTap: (index) {
                  _tabController.animateTo(index);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30.0))),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [PalawanMap(), Province(), Municipalities()],
              ),
            ),
          )
        ]));
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
          isSync = true;
        });
        FirebaseFirestore.instance
            .collection('voters')
            .snapshots()
            .listen((querySnapshot) {
          for (var change in querySnapshot.docChanges) {
            Voter? v = Voter.fromMap(change.doc.data(), change.doc.id);
            if (v != null) SqliteDB().updateVoterLocal(v);
          }
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Datasync"),
      content: Text("App will sync your data in the background."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
