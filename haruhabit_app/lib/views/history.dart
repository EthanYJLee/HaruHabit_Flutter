import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/views/habit_history.dart';
import 'package:haruhabit_app/views/schedule_history.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late int currentIndex;

  final List<Widget> tabbarItems = const [
    HabitHistory(),
    ScheduleHistory(),
  ];
  late List<bool> onSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = 0;
    onSelected = [true, false];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            icon: onSelected[0]
                ? Icon(
                    CupertinoIcons.calendar_circle_fill,
                    color: Colors.redAccent[100],
                  )
                : Icon(
                    CupertinoIcons.calendar_circle,
                    color: Colors.redAccent[100],
                  ),
            label: "습관",
          ),
          BottomNavigationBarItem(
            icon: onSelected[1]
                ? Icon(
                    CupertinoIcons.clock_fill,
                    color: Colors.redAccent[100],
                  )
                : Icon(
                    CupertinoIcons.clock,
                    color: Colors.redAccent[100],
                  ),
            label: "일정",
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
