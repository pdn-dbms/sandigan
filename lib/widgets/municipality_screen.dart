import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pol_dbms/config/styles.dart';
import 'package:pol_dbms/model/municipality_model.dart';
import 'package:pol_dbms/widgets/barangay_list.dart';
import 'package:pol_dbms/widgets/palawan_map.dart';
import 'package:pol_dbms/widgets/province.dart';
import 'package:pol_dbms/widgets/sangunian.dart';

class MunicipalityScreen extends StatefulWidget {
  final Municipality municipality;
  MunicipalityScreen({required this.municipality});
  @override
  _MunicipalityScreenState createState() => _MunicipalityScreenState();
}

class _MunicipalityScreenState extends State<MunicipalityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var initIndex = 0;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
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
        backgroundColor: const Color.fromRGBO(9, 2, 81, 1),
        appBar: AppBar(
          title: Text(widget.municipality.name),
          centerTitle: true,
        ),
        body: Column(children: <Widget>[
          DefaultTabController(
            length: 2,
            initialIndex: initIndex,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: const Color.fromRGBO(9, 2, 81, 1)),
              child: TabBar(
                controller: _tabController,
                indicator: BubbleTabIndicator(
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  indicatorHeight: 45.0,
                  indicatorColor: Colors.white,
                ),
                labelStyle: Styles.tabTextStyle,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white60,
                tabs: <Widget>[
                  Text('Officials'),
                  Text('Barangay'),
                ],
                onTap: (index) {
                  _tabController.animateTo(index);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30.0))),
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Sangunian(municipality: widget.municipality),
                  BarangayList(municipality: widget.municipality)
                ],
              ),
            ),
          )
        ]));
  }
}
