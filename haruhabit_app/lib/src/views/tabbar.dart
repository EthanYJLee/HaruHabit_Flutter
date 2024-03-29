import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:haruhabit_app/src/views/health.dart';
import 'package:haruhabit_app/src/views/home.dart';

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> with WidgetsBindingObserver {
  // 현재 선택된 탭
  late int currentIndex;

  final List<Widget> tabbarItems = const [
    Home(),
    Health(),
    // MyPage(),
  ];
  late List<bool> onSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    currentIndex = 0;
    onSelected = [true, false];
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
    debugPrint('Locale : ${context.locale}');
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/wallpaper.jpg'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            /// 언어 설정 버튼 (English / Korean)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PopupMenuButton(
                color: Colors.redAccent[100],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
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
                      onTap: () async {
                        await context.setLocale(const Locale("en", "US"));
                        await EasyLocalization.ensureInitialized();
                        Phoenix.rebirth(context);
                        // setState(() {});
                      },
                      child: const Text(
                        "English",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    PopupMenuItem(
                        onTap: () async {
                          await context.setLocale(const Locale("ko", "KR"));
                          await EasyLocalization.ensureInitialized();
                          Phoenix.rebirth(context);
                          // setState(() {});
                        },
                        child: const Text(
                          "한국어",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        )),
                  ];
                },
              ),
            )
          ],
        ),
        body: tabbarItems[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.redAccent[100],
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
            _changeOnSelected(value);
          },
          items: [
            BottomNavigationBarItem(
              icon: onSelected[0]
                  ? const Icon(CupertinoIcons.square_list_fill)
                  : const Icon(CupertinoIcons.square_list),
              label: "Planner",
            ),
            BottomNavigationBarItem(
              icon: onSelected[1]
                  ? const Icon(CupertinoIcons.heart_circle_fill)
                  : const Icon(CupertinoIcons.heart_circle),
              label: "Health",
            ),
            // BottomNavigationBarItem(
            //   icon: onSelected[2]
            //       ? const Icon(CupertinoIcons.person_fill)
            //       : const Icon(CupertinoIcons.person),
            //   label: "My Page",
            // ),
          ],
        ),
      ),
    );
  }

  _changeOnSelected(int index) {
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
