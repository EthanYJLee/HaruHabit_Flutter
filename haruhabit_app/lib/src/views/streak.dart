import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/habit_bloc.dart';
import 'package:haruhabit_app/src/blocs/streak_bloc.dart';
import 'package:haruhabit_app/src/models/streak_model.dart';
import 'package:haruhabit_app/src/utils/constant_widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

import '../blocs/calendar_bloc.dart';
import '../utils/calendar_utils.dart';
import '../utils/database_handler.dart';

class Streak extends StatefulWidget {
  const Streak({super.key, required this.hId, required this.startDate});
  final int hId;
  final String startDate;

  // final DateTime day;

  @override
  State<Streak> createState() => _StreakState();
}

//**  범위를 정해 이벤트를 받아올 경우 사용할 것
// List<Event> _getEventsForDays(Iterable<DateTime> days) {
//   return [
//     for (final d in days) ..._getEventsForDay(d),
//   ];
// }
//
// List<Event> _getEventsForRange(DateTime start, DateTime end) {
//   // Implementation example
//   final days = daysInRange(start, end);
//   return [
//     for (final d in days) ..._getEventsForDay(d),
//   ];
// }
//
// void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//   setState(() {
//     _selectedDay = null;
//     _focusedDay = focusedDay;
//     _rangeStart = start;
//     _rangeEnd = end;
//     _rangeSelectionMode = RangeSelectionMode.toggledOn;
//   });
//
//   // `start` or `end` could be null
//   if (start != null && end != null) {
//     _selectedEvents.value = _getEventsForRange(start, end);
//   } else if (start != null) {
//     _selectedEvents.value = _getEventsForDay(start);
//   } else if (end != null) {
//     _selectedEvents.value = _getEventsForDay(end);
//   }
// }
// */

// bool get canClearSelection =>
//     // _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;
//     _selectedDays.isNotEmpty;

class _StreakState extends State<Streak> {
  late final ValueNotifier<List<HabitStatus>> _habitStatus;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  // final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  late List<StreakModel> streakModel;
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  late int longestStreak = 0;
  DatabaseHandler handler = DatabaseHandler();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streakBloc.getStreakLists(widget.hId, DateTime.now().toString());
    _selectedDay = _focusedDay.value;
    _habitStatus = ValueNotifier(_getStreaksForDay(_selectedDay!));
    // _onDaySelected(_selectedDay!, _focusedDay.value);
  }

  List<HabitStatus> _getStreaksForDay(DateTime day) {
    // Implementation example
    return streakBloc.kStreaks[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        // _rangeStart = null; // Important to clean those
        // _rangeEnd = null;
        // _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
    _habitStatus.value = _getStreaksForDay(selectedDay);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Habit Status disposed');
    _habitStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    streakBloc.findLongestStreak(widget.hId);
    streakBloc.getCompletedLists(widget.hId);
    habitBloc.fetchSelectedHabit(widget.hId);
    habitBloc.fetchPercentage(widget.hId);
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/wallpaper.jpg'), // 배경 이미지
          ),
        ),
        height: MediaQuery.of(context).size.height / 1.1,
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: TextButton(
              onPressed: () {
                setState(() {
                  // _habitStatus.value = _getStreaksForDay(DateTime.now());
                  _selectedDay = DateTime.now();
                });
              },
              child: Text(
                "Today",
                style: TextStyle(
                  color: Colors.redAccent[100],
                ),
              ),
            ),
            actions: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: PopupMenuButton(
              //     color: Colors.redAccent[100],
              //     shape: const RoundedRectangleBorder(
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(20.0),
              //       ),
              //     ),
              //     icon: const Icon(
              //       Icons.remove_circle_outline,
              //       size: 30,
              //     ),
              //     onSelected: (value) {
              //       print(value);
              //       _endHabitDialog(context);
              //     },
              //     itemBuilder: (context) {
              //       return [
              //         PopupMenuItem(
              //           onTap: () {
              //             /// --
              //             /// 1. alert dialog
              //             /// 2. update habits (endDate <= DateTime.now())
              //             ///
              //             // setState(() {
              //             print("dsdf");
              //             _endHabitDialog(context);
              //             // });
              //           },
              //           child: const Text(
              //             "End this habit",
              //             style: TextStyle(
              //                 color: Colors.white, fontWeight: FontWeight.w500),
              //           ),
              //         ),
              //       ];
              //     },
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: TextButton(
              //       onPressed: () {
              //         _endHabitDialog(context);
              //       },
              //       style: TextButton.styleFrom(
              //           foregroundColor: Colors.redAccent[100]),
              //       child: const Text('Finish!')),
              // )
            ],
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(15)),
                    child: StreamBuilder(
                      stream: streakBloc.streakList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return TableCalendar<HabitStatus>(
                            locale: "en",
                            firstDay: kFirstDay,
                            lastDay: kLastDay,
                            focusedDay: _focusedDay.value,
                            rangeStartDay: DateTime.parse(widget.startDate),
                            rangeEndDay: DateTime.now(),
                            enabledDayPredicate: (day) =>
                                (DateTime.parse(widget.startDate)
                                    .isBefore(day)) &&
                                (DateTime.now()
                                    .add(const Duration(days: 1))
                                    .isAfter(day)),
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            calendarFormat: _calendarFormat,
                            eventLoader: _getStreaksForDay,
                            startingDayOfWeek: StartingDayOfWeek.sunday,
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: true,
                              markerSize: 40,
                              markersAnchor: 1,
                              markerDecoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                    image:
                                        AssetImage('assets/images/checked.png'),
                                    opacity: 0.6),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 0.7),
                              ),
                              todayDecoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 189, 183),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 138, 128),
                                shape: BoxShape.circle,
                              ),
                              // rangeStartDecoration: const BoxDecoration(),
                              // rangeEndDecoration: const BoxDecoration(),
                            ),
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              leftChevronIcon: Icon(
                                CupertinoIcons.arrow_left_circle,
                                color: Color.fromARGB(255, 255, 138, 128),
                              ),
                              rightChevronIcon: Icon(
                                CupertinoIcons.arrow_right_circle,
                                color: Color.fromARGB(255, 255, 138, 128),
                              ),
                            ),
                            onDaySelected: _onDaySelected,
                            onPageChanged: (focusedDay) =>
                                _focusedDay.value = focusedDay,
                          );
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
                Container(
                  height: MediaQuery.of(context).size.height / 5.5,
                  // width: MediaQuery.of(context).size.width / 1.04,
                  padding: const EdgeInsets.only(left: 7, right: 7),
                  child: Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Longest Streak 보여주는 StreamBuilder
                            _showLongestStreaks(),
                            const SizedBox(
                              width: 28,
                            ),

                            /// 전체 달성 일수 보여주는 StreamBuilder
                            _showAchievedDays(),
                            const SizedBox(
                              width: 28,
                            ),

                            /// 전체 진행 일수 보여주는 StreamBuilder
                            _showTotalDays(),
                            const SizedBox(
                              width: 28,
                            ),

                            /// 현재 진행상황 퍼센트로 보여주기
                            _showPercentage(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[100]),
                  onPressed: () {
                    setState(() {
                      streakBloc
                          .achievedTodaysGoal(widget.hId,
                              _selectedDay.toString().substring(0, 10))
                          .whenComplete(() => streakBloc.getStreakLists(
                              widget.hId,
                              _selectedDay.toString().substring(0, 10)));
                    });
                  },
                  child: Text(
                    "achievementButton".tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _endHabitDialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('End habit'),
  //           content: Text('Are you sure to finish this habit?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 //-
  //                 // handler
  //                 // .endHabit(DateTime.now().toString().substring(0, 10),
  //                 //     widget.hId.toString())
  //                 //     .whenComplete(() {
  //                 //   Navigator.pop(context);
  //                 //   Navigator.pop(context);
  //                 // });

  //                 /// 1. home까지 navigator.pop
  //                 /// 2. handler.endHabit(): update endDate
  //                 /// 3. home setstate? / fetch habit
  //                 // Navigator.pop(context);
  //                 // Navigator.pop(context);
  //                 // habitBloc.dispose();
  //                 // handler
  //                 //     .endHabit(DateTime.now().toString().substring(0, 10),
  //                 //         widget.hId.toString())
  //                 //     .whenComplete(() => setState(() {}));
  //               },
  //               child: Text(
  //                 'finish',
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 //-
  //                 Navigator.of(context).pop();
  //               },
  //               style: TextButton.styleFrom(foregroundColor: Colors.red),
  //               child: Text(
  //                 'back',
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

  StreamBuilder _showPercentage() {
    return StreamBuilder(
        stream: habitBloc.percentage,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              // padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('status'.tr()),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: CircularPercentIndicator(
                      backgroundColor: const Color.fromARGB(255, 188, 188, 188),
                      radius: 30.0,
                      lineWidth: 3.0,
                      percent: snapshot.data as double,
                      center: Text(
                        '${((snapshot.data as double) * 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      progressColor: Colors.redAccent[100],
                    ),
                  ),
                  const Text('%')
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Text('');
        });
  }

  StreamBuilder _showTotalDays() {
    return StreamBuilder(
        stream: habitBloc.totalDates,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('total'.tr()),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Stack(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(15),
                        decoration: ConstantWidgets.circularLineDecoration(),
                        child: _streakStatusText(snapshot.data.toString()),
                      )
                    ],
                  ),
                ),
                (snapshot.data == 0 || snapshot.data == 1)
                    ? Text('day'.tr())
                    : Text('days'.tr())
              ],
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Text('');
        });
  }

  StreamBuilder _showAchievedDays() {
    return StreamBuilder(
        stream: streakBloc.totalCompleted,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('completed'.tr()),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Stack(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(15),
                        decoration: ConstantWidgets.circularLineDecoration(),
                        child: _streakStatusText(snapshot.data.toString()),
                      )
                    ],
                  ),
                ),
                (snapshot.data == 0 || snapshot.data == 1)
                    ? Text('day'.tr())
                    : Text('days'.tr())
              ],
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Text('');
        });
  }

  StreamBuilder _showLongestStreaks() {
    return StreamBuilder(
        stream: streakBloc.longestStreak,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('streaks'.tr()),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Stack(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(15),
                        decoration: ConstantWidgets.circularLineDecoration(),
                        child: _streakStatusText(snapshot.data.toString()),
                      )
                    ],
                  ),
                ),
                (snapshot.data == 0 || snapshot.data == 1)
                    ? Text('day'.tr())
                    : Text('days'.tr())
              ],
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Text('');
        });
  }

  Widget _streakStatusText(String data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
