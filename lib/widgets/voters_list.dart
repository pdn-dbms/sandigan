import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pol_dbms/model/voter.dart';
import 'package:pol_dbms/services/sqlite_db.dart';
import 'package:pol_dbms/widgets/voter_tag.dart';

class VotersList extends StatefulWidget {
  final String muni;
  final String brgy;
  VotersList({required this.muni, required this.brgy});
  @override
  _VotersListState createState() => _VotersListState();
}

class _VotersListState extends State<VotersList> {
  TextEditingController controller = new TextEditingController();
  final SlidableController slidableController = SlidableController();
  List<Voter> _searchResult = [];
  List<Voter> voters = [];

  getVotersList() async {
    SqliteDB()
        .getVotersByBrgy(muni: widget.muni, brgy: widget.brgy)
        .then((value) {
      setState(() {
        voters = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getVotersList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.search),
                title: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: 'Search voters', border: InputBorder.none),
                  onChanged: onSearchTextChanged,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    controller.clear();
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchResult.length != 0 || controller.text.isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    final _data = _searchResult[index];

                    String name = _data.name;

                    return Slidable(
                      controller: slidableController,
                      actionExtentRatio: 0.5,
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Assist',
                          color: Colors.blue,
                          icon: Icons.verified_user_rounded,
                        ),
                        IconSlideAction(
                            caption: 'Tag',
                            color: Colors.yellow,
                            icon: Icons.tag_faces_rounded,
                            onTap: () {
                              ShowTag(context, _data.id, index, 'search');
                            }),
                      ],
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(0.0),
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: _data.tagAs == 'ACA Supporter'
                                      ? Colors.blueAccent
                                      : Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: _data.tagAs == 'ACA Supporter'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  Text('Precinct No. : ' + _data.precinct,
                                      style: TextStyle(
                                          color: _data.tagAs == 'ACA Supporter'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: voters.length,
                  itemBuilder: (context, index) {
                    final _data = voters[index];

                    final name = _data.name;

                    return Slidable(
                      controller: slidableController,
                      actionExtentRatio: 0.5,
                      actionPane: const SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        const IconSlideAction(
                            caption: 'Assist',
                            color: Colors.blue,
                            icon: Icons.verified_user_rounded),
                        IconSlideAction(
                            caption: 'Tag',
                            color: Colors.yellow,
                            icon: Icons.tag_faces_rounded,
                            onTap: () {
                              ShowTag(context, _data.id, index, 'all');
                            })
                      ],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0.0, top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(0.0),
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: _data.tagAs == 'ACA Supporter'
                                      ? Colors.blueAccent
                                      : Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: _data.tagAs == 'ACA Supporter'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                  Text('Precinct No. : ' + _data.precinct,
                                      style: TextStyle(
                                          color: _data.tagAs == 'ACA Supporter'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void UpdateList(int index, String tag, String dataSource) {
    setState(() {
      if (dataSource == 'search') {
        _searchResult[index].tagAs = tag;
        SqliteDB().updateVoter(_searchResult[index]);
      } else {
        voters[index].tagAs = tag;
        SqliteDB().updateVoter(voters[index]);
      }
    });
  }

  void UpdateListAssistance(int index, String tag, String dataSource) {
    setState(() {
      if (dataSource == 'search') {
        _searchResult[index].tagAs = tag;
        SqliteDB().updateVoter(_searchResult[index]);
      } else {
        voters[index].tagAs = tag;
        SqliteDB().updateVoter(voters[index]);
      }
    });
  }

  void ShowTag(BuildContext context, String id, int index, String dataSource) {
    const tags = [
      'ACA Supporter',
      'Not Tag',
      'With JPM ID',
      'Deceased',
      'Moved Out',
      'Not Supporter'
    ];
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            for (var tag in tags)
              ListTile(
                title: Text(tag,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onTap: () {
                  UpdateList(index, tag, dataSource);
                  Navigator.pop(context);
                },
              )
          ]);
        });
  }

  void ShowAssistance(
      BuildContext context, String id, int index, String dataSource) {
    const tags = [
      'Financial - Cash',
      'Financial - AICS',
      'Financial - Tupad',
      'Educational - Cash',
      'Educational - DSWD',
      'Medical - DSWD',
      'Medical - Hospital',
    ];
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            for (var tag in tags)
              ListTile(
                title: Text(tag,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                onTap: () {
                  UpdateListAssistance(index, tag, dataSource);
                  Navigator.pop(context);
                },
              )
          ]);
        });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    voters.forEach((userDetail) {
      if (userDetail.name.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.precinct.toLowerCase() == text.toLowerCase() ||
          userDetail.tagAs.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
      }
    });

    setState(() {});
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }
}
