import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/views/habit_history.dart';
import 'package:haruhabit_app/src/views/schedule_history.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/calendar_utils.dart';

class HistoryTabbar extends StatefulWidget {
  const HistoryTabbar({super.key, required this.initialView});
  final int initialView;

  @override
  State<HistoryTabbar> createState() => _HistoryTabbarState();
}

class _HistoryTabbarState extends State<HistoryTabbar> {
  late int currentIndex;

  final List<Widget> tabbarItems = [
    ScheduleHistory(),
    HabitHistory(),
  ];
  late List<bool> onSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = widget.initialView;
    onSelected = [true, false];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        elevation: 0,
      ),
      body: tabbarItems[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle:
            TextStyle(color: Colors.redAccent[100], fontSize: 14),
        // backgroundColor: const Color(0xFF084A76),
        fixedColor: Colors.redAccent[100],
        unselectedItemColor: Colors.redAccent[100],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          changeOnselected(value);
        },
        items: [
          BottomNavigationBarItem(
            // icon: onSelected[0]
            icon: currentIndex == 0
                ? Icon(
                    CupertinoIcons.calendar_circle_fill,
                    color: Colors.redAccent[100],
                  )
                : Icon(
                    CupertinoIcons.calendar_circle,
                    color: Colors.redAccent[100],
                  ),
            label: "Habit",
          ),
          BottomNavigationBarItem(
            // icon: onSelected[1]
            icon: currentIndex == 1
                ? Icon(
                    CupertinoIcons.clock_fill,
                    color: Colors.redAccent[100],
                  )
                : Icon(
                    CupertinoIcons.clock,
                    color: Colors.redAccent[100],
                  ),
            label: "To-Do",
          ),
        ],
      ),
    );
  }

  changeOnselected(int index) {
    for (var i = 0; i < 2; i++) {
      if (i == index) {
        onSelected[i] = true;
      } else {
        onSelected[i] = false;
      }
    }

    setState(() {});
  }
}
