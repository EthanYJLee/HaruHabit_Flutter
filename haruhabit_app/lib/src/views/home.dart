import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/src/utils/gridcard_util.dart';
import 'package:haruhabit_app/src/utils/header.dart';
import 'package:haruhabit_app/src/views/calendar.dart';

import '../blocs/schedule_bloc.dart';
import '../models/schedule_model.dart';
import '../utils/card_dialog.dart';
import '../utils/add_habit.dart';
import '../utils/timeline_util.dart';
import 'history_tabbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // 선택되어있는 날짜의 일정 fetch
    scheduleBloc.fetchAllSchedules();
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   // actions: [
        //   //   IconButton(
        //   //       onPressed: () {
        //   //         Navigator.of(context)
        //   //             .push(MaterialPageRoute(
        //   //                 builder: (context) => const Calendar()))
        //   //             .whenComplete(() => scheduleBloc.fetchAllSchedules());
        //   //       },
        //   //       icon: const Icon(Icons.add))
        //   // ],
        // ),
        body: Center(
          child: Column(
            children: [
              const TimelineUtil(),
              const Divider(
                thickness: 3,
              ),
              // _header('To-Do'),
              const Header(title: 'To-Do'),
              GridcardUtil(
                content: Container(
                  height: MediaQuery.of(context).size.height / 8,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: StreamBuilder(
                    stream: scheduleBloc.selectedSchedule,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // print(snapshot.data!.length);
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: InkWell(
                                    child: GestureDetector(
                                  onTap: () async {
                                    ScheduleModel scheduleModel = ScheduleModel(
                                      sId: snapshot.data?[index].sId,
                                      date: "${snapshot.data?[index].date}",
                                      schedule:
                                          "${snapshot.data?[index].schedule}",
                                      place: "${snapshot.data?[index].place}",
                                      hour: "${snapshot.data?[index].hour}",
                                      minute: "${snapshot.data?[index].minute}",
                                    );
                                  },
                                  child: Card(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        // Text('id : ${snapshot.data?[index].sId}'),
                                        Text('${snapshot.data?[index].date}'),
                                        Text(
                                            '${snapshot.data?[index].schedule}'),
                                        // Text('place : ${snapshot.data?[index].place}'),
                                        Text(
                                            '${snapshot.data?[index].hour}:${snapshot.data?[index].minute}'),
                                      ],
                                    ),
                                  ),
                                )),
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              const Header(title: 'Plan'),
              GridcardUtil(
                content: Container(
                  height: MediaQuery.of(context).size.height / 8,
                  width: MediaQuery.of(context).size.width / 1.1,
                ),
              ),
            ],
          ),
        ),

        /// Desc : 습관 및 일정을 추가하는 Floating Action Button
        /// Date : 2023.06.01
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SpeedDial(
          backgroundColor: Colors.redAccent[100],
          overlayColor: Colors.black,
          icon: Icons.add,
          activeIcon: Icons.close,
          direction: SpeedDialDirection.up,
          childPadding: const EdgeInsets.all(5),
          spaceBetweenChildren: 4,
          spacing: 3,
          useRotationAnimation: true,
          animationCurve: Curves.easeInOutQuart,
          children: [
            SpeedDialChild(
              child: const Icon(CupertinoIcons.calendar),
              label: "습관 추가",
              labelBackgroundColor: Colors.transparent,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              // onTap: () => showSearchView(),
              onTap: () {
                // Navigator.of(context).push(CardDialog(builder: (context) {
                //   return const CreateHabit();
                // })).then((_) {
                //   setState(() {});
                // });
              },
            ),
            SpeedDialChild(
                child: const Icon(CupertinoIcons.clock),
                label: "일정 추가",
                labelBackgroundColor: Colors.transparent,
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                // onTap: () => showSortDialog(),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Calendar()));
                }),
            SpeedDialChild(
              child: const Icon(CupertinoIcons.list_bullet),
              label: "목록 보기",
              labelBackgroundColor: Colors.transparent,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HistoryTabbar()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // 각 Grid Card의 Header
  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "View all",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Home 화면 Drawer
  Widget _drawer() {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 100,
            child: DrawerHeader(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              '사용자 설정',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: ListTile(
              title: const Text('회원정보 수정', style: TextStyle(fontSize: 14)),
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              onTap: () {
                print('회원정보 수정');
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: ((context) => )));
              },
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              '기타',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  title: const Text('로그아웃', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    // _logOut(context);
                  },
                ),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  title: const Text('회원탈퇴', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    // _deleteAccount(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
