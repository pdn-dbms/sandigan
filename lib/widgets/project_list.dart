import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({Key? key}) : super(key: key);

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  TextEditingController controller = TextEditingController();
  final SlidableController slidableController = SlidableController();
  List<Map<String, dynamic>> _searchResult = [];
  List<Map<String, dynamic>> projects = [];
  Future<Null> getProjectList() async {
    var docs = await FirebaseFirestore.instance.collection('projects').get();
    setState(() {
      docs.docs.forEach((doc) {
        projects.add(doc.data());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getProjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
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
                    hintText: 'Search projects', border: InputBorder.none),
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

                  final name = (_data as dynamic)['title'].toString();

                  return Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                (_data as dynamic)['brgy'].toString() +
                                    ' ' +
                                    (_data as dynamic)['muni'].toString(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        Divider()
                      ],
                    ),
                  );
                },
              )
            : ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final _data = projects[index];

                  final name = (_data as dynamic)['title'].toString();

                  return Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                (_data as dynamic)['brgy'].toString() +
                                    ' ' +
                                    (_data as dynamic)['muni'].toString(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        Divider()
                      ],
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    projects.forEach((project) {
      if (project['title'].toLowerCase().contains(text))
        _searchResult.add(project);
    });

    setState(() {});
  }
}
