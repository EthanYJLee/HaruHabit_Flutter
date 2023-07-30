import 'dart:async';

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/src/blocs/habit_bloc.dart';
import 'package:haruhabit_app/src/utils/calendar_utils.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:haruhabit_app/src/utils/gridcard_util.dart';
import 'package:haruhabit_app/src/utils/home_drawer.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:haruhabit_app/src/views/habit_status.dart';
import 'package:haruhabit_app/src/views/planner.dart';
import 'package:haruhabit_app/src/views/streak.dart';

import '../blocs/calendar_bloc.dart';
import '../blocs/schedule_bloc.dart';
import '../models/schedule_model.dart';
import '../utils/card_dialog.dart';
import '../utils/add_habit.dart';
import 'history_tabbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DateTime _selectedDate = DateTime.now();
  final _categoryLists = <String, IconData>{
    'smoke free': Icons.smoke_free,
    'no drinks': Icons.no_drinks,
    'drink water': Icons.water_drop_outlined,
    'save money': Icons.attach_money,
    'workout': Icons.fitness_center,
    'custom': Icons.add_task
  }.entries;

  IconData getCategoryIcons(String feature) {
    print(_categoryLists
        .firstWhere((key) => key.toString().contains(feature))
        .value
        .runtimeType);
    return _categoryLists
        .firstWhere((key) => key.toString().contains(feature))
        .value;
  }

  @override
  Widget build(BuildContext context) {
    // 선택되어있는 날짜의 일정 fetch
    scheduleBloc
        .fetchSelectedSchedules(_selectedDate.toString().substring(0, 10));
    // 진행중인 습관 fetch
    habitBloc.fetchAllHabits();
    return SafeArea(
      child: Container(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Divider(thickness: 2, color: Colors.white),
                  Container(
                    child: Column(
                      children: [
                        _timeline(),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                          ),
                          child: Text(
                            'today'.tr(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => setState(() => resetSelectedDate()),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2, color: Colors.white),
                  //**
                  //
                  //
                  //
                  //
                  //
                  // */ --------------------------- Schedule ---------------------------
                  Container(
                    padding: const EdgeInsets.only(left: 30, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'todo'.tr(),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            // 선택한 날짜의 일정 수 버튼으로 보여주기
                            StreamBuilder(
                                stream: scheduleBloc.selectedSchedule,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.isNotEmpty) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                12,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                8,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.redAccent[100]),
                                          ),
                                          child:
                                              Text("${snapshot.data!.length}"),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  return const SizedBox();
                                }),
                          ],
                        ),
                        Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                Calendar(day: DateTime.now())))
                                        .whenComplete(() {
                                      scheduleBloc.fetchSelectedSchedules(
                                          DateTime.now()
                                              .toString()
                                              .substring(0, 10));
                                    });
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                const HistoryTabbar(
                                                    initialView: 0)))
                                        .whenComplete(() {
                                      scheduleBloc.fetchSelectedSchedules(
                                          DateTime.now()
                                              .toString()
                                              .substring(0, 10));
                                    });
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.right_chevron,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: scheduleBloc.selectedSchedule,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return Container(
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Flex(
                                    direction: Axis.horizontal,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // Navigator.of(context).push(
                                          //     _createRoute(DateTime.parse(
                                          //         snapshot.data![index].date
                                          //             .toString())));
                                          // print(MediaQuery.of(context)
                                          //     .viewInsets
                                          //     .bottom);
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  6,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.7,
                                              child: Card(
                                                color: Colors.white,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                elevation: 3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: (snapshot
                                                                    .data![
                                                                        index]
                                                                    .isDone ==
                                                                0)
                                                            ? IconButton(
                                                                onPressed: () {
                                                                  scheduleBloc
                                                                      .scheduleIsDone(
                                                                          1,
                                                                          snapshot
                                                                              .data![
                                                                                  index]
                                                                              .sId
                                                                              .toString())
                                                                      .whenComplete(
                                                                          () {
                                                                    setState(
                                                                        () {
                                                                      calendarBloc
                                                                          .getEventLists();
                                                                    });
                                                                  });
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .check_box_outlined,
                                                                ),
                                                              )
                                                            : IconButton(
                                                                onPressed: () {
                                                                  scheduleBloc
                                                                      .scheduleIsDone(
                                                                          0,
                                                                          snapshot
                                                                              .data![
                                                                                  index]
                                                                              .sId
                                                                              .toString())
                                                                      .whenComplete(
                                                                          () {
                                                                    setState(
                                                                        () {
                                                                      calendarBloc
                                                                          .getEventLists();
                                                                    });
                                                                  });
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .check_box)),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${snapshot.data?[index].hour.toString().padLeft(2, "0")}:${snapshot.data?[index].minute.toString().padLeft(2, "0")}',
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Text(
                                                        '${snapshot.data?[index].schedule}',
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    Text(
                                                      '@ ${snapshot.data?[index].place}',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                  const Divider(thickness: 2, color: Colors.white),
                  //**
                  //
                  //
                  //
                  //
                  //
                  // */ --------------------------- Habit ---------------------------
                  Container(
                    padding: const EdgeInsets.only(left: 30, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'habit'.tr(),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            StreamBuilder(
                                stream: habitBloc.habitOnProgress,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.isNotEmpty) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                12,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                8,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.redAccent[100]),
                                          ),
                                          child:
                                              Text("${snapshot.data!.length}"),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  return const SizedBox();
                                }),
                          ],
                        ),
                        Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(CardDialog(
                                            builder: (context) =>
                                                const AddHabit()))
                                        .whenComplete(() {
                                      // habitBloc.fetchHabitsOnProgress(
                                      //     (_selectedDate.year.toString() +
                                      //         '-' +
                                      //         _selectedDate.month
                                      //             .toString()
                                      //             .padLeft(2, "0") +
                                      //         '-' +
                                      //         _selectedDate.day
                                      //             .toString()
                                      //             .padLeft(2, "0")));
                                      habitBloc.fetchAllHabits();
                                    });
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                const HistoryTabbar(
                                                    initialView: 1)))
                                        .whenComplete(() {
                                      // scheduleBloc.fetchSelectedSchedules(
                                      //     DateTime.now()
                                      //         .toString()
                                      //         .substring(0, 10));
                                      setState(() {});
                                    });
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.right_chevron,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // 진행중인 습관 보여주기
                  StreamBuilder(
                      stream: habitBloc.allHabit,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isNotEmpty) {
                            return Container(
                              height: (snapshot.data!.length < 4)
                                  ? MediaQuery.of(context).size.height /
                                      (12 / snapshot.data!.length)
                                  : MediaQuery.of(context).size.height / 4,
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Flex(
                                      direction: Axis.vertical,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              return showHabitsBottomSheet(
                                                  context,
                                                  snapshot.data![index].hId
                                                      .toString());
                                            },
                                            child:
                                                (_selectedDate
                                                            .difference(DateTime
                                                                .parse(snapshot
                                                                    .data![
                                                                        index]
                                                                    .startDate))
                                                            .inDays >=
                                                        0)
                                                    ? Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            12,
                                                        child: Card(
                                                          color: Colors.white,
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          15))),
                                                          elevation: 3,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(5),
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color: Colors
                                                                                .white),
                                                                        color: Colors
                                                                            .red[100]),
                                                                    child: Icon(getCategoryIcons(snapshot
                                                                        .data![
                                                                            index]
                                                                        .category
                                                                        .toString())),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(5),
                                                                    child: Text(
                                                                      '${snapshot.data?[index].habit}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            15),
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.black,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        (DateTime.now().difference(DateTime.parse(snapshot.data![index].startDate)).isNegative)
                                                                            ? Container()
                                                                            : Text(
                                                                                "+${_selectedDate.difference(DateTime.parse(snapshot.data![index].startDate)).inDays + 1}",
                                                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container()),
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
                      }),

                  // InkWell(
                  //   onTap: () {
                  //     Navigator.of(context)
                  //         .push(CardDialog(
                  //             builder: (context) => const AddHabit()))
                  //         .whenComplete(() {
                  //       habitBloc.fetchAllHabits();
                  //     });
                  //   },
                  //   child: GridcardUtil(
                  //       content: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: const [
                  //             Icon(
                  //               CupertinoIcons.add_circled,
                  //               size: 30,
                  //             ),
                  //           ]),
                  //     ],
                  //   )),
                  // ),
                ],
              ),
            ),
          ),

          /// Desc : 습관 및 일정을 추가하고 조회하는 Floating Action Button
          /// Date : 2023.06.01
          // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          // floatingActionButton: SpeedDial(
          //   backgroundColor: Colors.redAccent[100],
          //   overlayColor: Colors.black,
          //   icon: Icons.add,
          //   activeIcon: Icons.close,
          //   direction: SpeedDialDirection.up,
          //   childPadding: const EdgeInsets.all(5),
          //   spaceBetweenChildren: 4,
          //   spacing: 3,
          //   useRotationAnimation: true,
          //   animationCurve: Curves.easeInOutQuart,
          //   children: [
          //     SpeedDialChild(
          //       child: const Icon(CupertinoIcons.calendar),
          //       label: "Add Habit",
          //       labelBackgroundColor: Colors.redAccent[100],
          //       labelStyle: const TextStyle(color: Colors.white),
          //       backgroundColor: Colors.redAccent[100],
          //       foregroundColor: Colors.white,
          //       // onTap: () => showSearchView(),
          //       onTap: () {
          //         Navigator.of(context).push(
          //             MaterialPageRoute(builder: (context) => const Planner()));
          //         // .whenComplete(() => scheduleBloc.fetchAllSchedules());
          //       },
          //     ),
          //     SpeedDialChild(
          //         child: const Icon(CupertinoIcons.clock),
          //         label: "Add To-Do",
          //         labelBackgroundColor: Colors.redAccent[100],
          //         labelStyle: const TextStyle(color: Colors.white),
          //         backgroundColor: Colors.redAccent[100],
          //         foregroundColor: Colors.white,
          //         // onTap: () => showSortDialog(),
          //         onTap: () {
          //           Navigator.of(context)
          //               .push(MaterialPageRoute(
          //                   builder: (context) => const Calendar()))
          //               .whenComplete(() => scheduleBloc.fetchAllSchedules());
          //         }),
          //     SpeedDialChild(
          //       child: const Icon(CupertinoIcons.list_bullet),
          //       label: "View History",
          //       labelBackgroundColor: Colors.redAccent[100],
          //       labelStyle: const TextStyle(color: Colors.white),
          //       backgroundColor: Colors.redAccent[100],
          //       foregroundColor: Colors.white,
          //       onTap: () {
          //         Navigator.of(context).push(MaterialPageRoute(
          //             builder: (context) => const HistoryTabbar(
          //                   initialView: 0,
          //                 )));
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  void resetSelectedDate() {
    // _selectedDate = DateTime.now().add(const Duration(days: 2));
    _selectedDate = DateTime.now();
  }

  Widget _timeline() {
    return Container(
      // color: Colors.transparent,
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: CalendarTimeline(
        // shrink: true,
        // showYears: true,
        initialDate: _selectedDate,
        // firstDate: DateTime.now().subtract(const Duration(days: 365)),
        firstDate: DateTime(2000, 1, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        // onDateSelected: (date) => print(date),
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        leftMargin: 20,
        monthColor: Colors.blueGrey[100],
        dayColor: Colors.white,
        activeDayColor: Colors.white,
        activeBackgroundDayColor: Colors.redAccent[100],
        dotsColor: const Color(0xFF333A47),
        // locale: 'ko',
        // locale: 'en',
      ),
    );
  }

  // void showSizeBottomSheet(BuildContext context, Map<String, int> sizes) {
  void showHabitsBottomSheet(BuildContext context, String hId) {
    showModalBottomSheet(
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.46,
        minChildSize: 0.45,
        maxChildSize: 0.46,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              color: Colors.white,
              child: Streak(hId: hId, day: DateTime.now()),
            ),
          );
        },
      ),
    );
  }
}

Route _createRoute(DateTime selectedDate) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Calendar(
      day: selectedDate,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      // const end = Offset.zero;
      const end = Offset(0.0, 0.0);
      var curve = Curves.easeIn;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );
      return SlideTransition(
        // position: offsetAnimation,
        // position: animation.drive(tween),
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}
