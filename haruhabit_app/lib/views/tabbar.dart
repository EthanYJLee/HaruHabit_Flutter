import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/views/calendar.dart';
import 'package:haruhabit_app/views/home.dart';
import 'package:haruhabit_app/views/mypage.dart';

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  late int currentIndex;

  final List<Widget> tabbarItems = const [
    Calendar(),
    // Customize(),
    Home(),
    MyPage(),
    // HealthKit()
  ];
  late List<bool> onSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = 1;
    // onSelected = [false, false, true, false, false];
    onSelected = [false, true, false];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabbarItems[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
                ? const Icon(CupertinoIcons.calendar_circle_fill)
                : const Icon(CupertinoIcons.calendar_circle),
            label: "달력",
          ),
          BottomNavigationBarItem(
            icon: onSelected[1]
                ? const Icon(CupertinoIcons.house_fill)
                : const Icon(CupertinoIcons.house),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: onSelected[2]
                ? const Icon(CupertinoIcons.person_fill)
                : const Icon(CupertinoIcons.person),
            label: "마이페이지",
          ),
          // BottomNavigationBarItem(
          //     icon: onSelected[4]
          //         ? const Icon(CupertinoIcons.heart_fill)
          //         : const Icon(CupertinoIcons.heart),
          //     label: "Health Kit")
        ],
      ),
    );
  }

  changeOnselected(int index) {
    for (var i = 0; i < 3; i++) {
      if (i == index) {
        onSelected[i] = true;
      } else {
        onSelected[i] = false;
      }
    }

    setState(() {});
  }
}
