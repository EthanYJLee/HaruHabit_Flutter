import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/src/utils/calendar_utils.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:haruhabit_app/src/utils/gridcard_util.dart';
import 'package:haruhabit_app/src/utils/header.dart';
import 'package:haruhabit_app/src/utils/home_drawer.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:haruhabit_app/src/views/planner.dart';

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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const TimelineUtil(),
                const Divider(
                  thickness: 3,
                ),
                Header(
                  title: "todo".tr(),
                  destination: const HistoryTabbar(
                    initialView: 0,
                  ),
                ),
                StreamBuilder(
                  stream: scheduleBloc.selectedSchedule,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return Container(
                          height: MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.7,
                                      child: Card(
                                        color: const Color.fromARGB(
                                            255, 255, 238, 225),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        elevation: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${snapshot.data?[index].hour.toString().padLeft(2, "0")}:${snapshot.data?[index].minute.toString().padLeft(2, "0")}',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              '${snapshot.data?[index].schedule}',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                                'at ${snapshot.data?[index].place}')
                                          ],
                                        ),
                                      ),
                                    ),
                                    // 일정 완료 버튼
                                    // Positioned(
                                    //     right: 1,
                                    //     top: 1,
                                    //     child: CheckButton(
                                    //       isDone: snapshot.data![index].isDone,
                                    //       sId: snapshot.data![index].sId
                                    //           .toString(),
                                    //     )),
                                  ],
                                );
                              }),
                        );
                      } else {
                        return Container();
                      }
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const Calendar(),
                          ),
                        )
                        .whenComplete(() => scheduleBloc.fetchAllSchedules());
                  },
                  child: GridcardUtil(
                      content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.add_circled,
                              size: 30,
                            ),
                          ]),
                    ],
                  )),
                ),
                const Divider(
                  thickness: 3,
                ),
                Header(
                    title: "plan".tr(),
                    destination: const HistoryTabbar(
                      initialView: 1,
                    )),
                InkWell(
                  onTap: () {
                    // Navigator.of(context)
                    //     .push(MaterialPageRoute(
                    //         builder: (context) => const Calendar()))
                    //     .whenComplete(() => scheduleBloc.fetchAllSchedules());
                    Navigator.of(context).push(CardDialog(builder: (context) {
                      return const AddHabit();
                    }));
                  },
                  child: GridcardUtil(
                      content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.add_circled,
                              size: 30,
                            ),
                          ]),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),

        /// Desc : 습관 및 일정을 추가하고 조회하는 Floating Action Button
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
              label: "Add Habit",
              labelBackgroundColor: Colors.redAccent[100],
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              // onTap: () => showSearchView(),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Planner()));
                // .whenComplete(() => scheduleBloc.fetchAllSchedules());
              },
            ),
            SpeedDialChild(
                child: const Icon(CupertinoIcons.clock),
                label: "Add To-Do",
                labelBackgroundColor: Colors.redAccent[100],
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.redAccent[100],
                foregroundColor: Colors.white,
                // onTap: () => showSortDialog(),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const Calendar()))
                      .whenComplete(() => scheduleBloc.fetchAllSchedules());
                }),
            SpeedDialChild(
              child: const Icon(CupertinoIcons.list_bullet),
              label: "View History",
              labelBackgroundColor: Colors.redAccent[100],
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HistoryTabbar(
                          initialView: 0,
                        )));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class CheckButton extends StatefulWidget {
//   const CheckButton({super.key, required this.isDone, required this.sId});
//   final int isDone;
//   final String sId;

//   @override
//   State<CheckButton> createState() => _CheckButtonState();
// }

// class _CheckButtonState extends State<CheckButton> {
//   DatabaseHandler _handler = DatabaseHandler();
//   late bool _isChecked;
//   late Icon checkIcon = Icon(
//     CupertinoIcons.checkmark_alt_circle,
//   );
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (widget.isDone == 0) {
//       _isChecked = false;
//       checkIcon = const Icon(
//         CupertinoIcons.checkmark_alt_circle,
//       );
//     } else {
//       _isChecked = true;
//       checkIcon = const Icon(
//         CupertinoIcons.checkmark_alt_circle_fill,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//         onPressed: () {
//           // -----------
//           setState(() {
//             _isChecked = !_isChecked;
//             if (_isChecked) {
//               _handler.scheduleIsDone(1, widget.sId);
//               checkIcon = const Icon(
//                 CupertinoIcons.checkmark_alt_circle_fill,
//               );
//             } else {
//               _handler.scheduleIsDone(0, widget.sId);
//               checkIcon = const Icon(
//                 CupertinoIcons.checkmark_alt_circle,
//               );
//             }
//           });
//         },
//         icon: checkIcon);
//   }
// }
