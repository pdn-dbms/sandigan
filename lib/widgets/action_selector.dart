import 'package:flutter/material.dart';
import 'package:pol_dbms/main.dart';

class ActionSelector extends StatefulWidget {
  const ActionSelector({Key? key}) : super(key: key);

  @override
  _ActionSelectorState createState() => _ActionSelectorState();
}

class _ActionSelectorState extends State<ActionSelector> {
  int selectedIndex = 0;
  final List<String> actions = ['Map', 'Municipalities', 'Province'];
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 90.0,
        color: Theme.of(context).colorScheme.primary,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  child: Text(actions[index],
                      style: TextStyle(
                          color: index == selectedIndex
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                ),
              );
            }));
  }
}
