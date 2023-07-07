import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:haruhabit_app/src/views/health.dart';
import 'package:haruhabit_app/src/views/home.dart';
import 'package:haruhabit_app/src/views/mypage.dart';

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> with WidgetsBindingObserver {
  late int currentIndex;

  final List<Widget> tabbarItems = const [
    Health(),
    Home(),
    MyPage(),
  ];
  late List<bool> onSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentIndex = 1;
    onSelected = [false, true, false];
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed');
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.detached:
        // DO SOMETHING when app deactivated abnormally
        scheduleBloc.dispose();
        // Calendar.state.dispose
        print('detached');
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          /// 언어 설정 버튼 (English / Korean)
          /// -------------------------bloc으로 변경-------------------------
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton(
              icon: const Icon(
                Icons.language,
                size: 30,
              ),
              onSelected: (value) {
                print(value);
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      // EasyLocalization.of(context)!.setLocale(
                      //   const Locale(
                      //     "en",
                      //     "US",
                      //   ),
                      // );
                      setState(() {
                        EasyLocalization.of(context)!.setLocale(
                          const Locale(
                            "en",
                            "US",
                          ),
                        );
                      });
                    },
                    child: const Text(
                      "english",
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // EasyLocalization.of(context)!.setLocale(
                      //   const Locale(
                      //     "ko",
                      //     "KR",
                      //   ),
                      // );
                      setState(() {
                        EasyLocalization.of(context)!.setLocale(
                          const Locale(
                            "ko",
                            "KR",
                          ),
                        );
                      });
                    },
                    child: const Text(
                      "korean",
                    ),
                  ),
                ];
              },
            ),
          )
        ],
      ),
      body: tabbarItems[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.redAccent[100],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          _changeOnselected(value);
        },
        items: [
          BottomNavigationBarItem(
            icon: onSelected[0]
                ? const Icon(CupertinoIcons.heart_circle_fill)
                : const Icon(CupertinoIcons.heart_circle),
            label: "Health",
          ),
          BottomNavigationBarItem(
            icon: onSelected[1]
                ? const Icon(CupertinoIcons.house_fill)
                : const Icon(CupertinoIcons.house),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: onSelected[2]
                ? const Icon(CupertinoIcons.person_fill)
                : const Icon(CupertinoIcons.person),
            label: "My Page",
          ),
        ],
      ),
    );
  }

  _changeOnselected(int index) {
    for (var i = 0; i < tabbarItems.length; i++) {
      if (i == index) {
        onSelected[i] = true;
      } else {
        onSelected[i] = false;
      }
    }

    setState(() {});
  }
}
