import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/streak_bloc.dart';
import 'package:haruhabit_app/src/models/streak_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../blocs/calendar_bloc.dart';
import '../utils/calendar_utils.dart';

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
            // actions: [
            //   IconButton(
            //       // Schedule 추가하고 돌아오면 일정 리스트 다시 불러오기
            //       onPressed: () {
            //         // Navigator.of(context).push(CardDialog(builder: (context) {
            //         //   return AddSchedule(selectedDate: _selectedDay!);
            //         // })).whenComplete(() {
            //         //   calendarBloc.getEventLists();
            //         //   _selectedEvents.value = _getEventsForDay(_selectedDay!);
            //         // });
            //       },
            //       icon: const Icon(CupertinoIcons.add_circled))
            // ],
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
                                (DateTime.now().isAfter(day)),
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
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[100]),
                    onPressed: () {
                      //-
                      // print(_selectedDay);
                      // print(_focusedDay.value);
                      setState(() {
                        streakBloc
                            .achievedTodaysGoal(widget.hId,
                                _selectedDay.toString().substring(0, 10))
                            .whenComplete(() => streakBloc.getStreakLists(
                                widget.hId,
                                _selectedDay.toString().substring(0, 10)));
                      });
                    },
                    child: const Text("Achieved Today's Goal!")),
                Container(
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width / 1.04,
                  // padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 3,
                    child: Row(
                      children: [
                        StreamBuilder(
                            stream: streakBloc.longestStreak,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                print(snapshot.data);
                                return (snapshot.data == 0 ||
                                        snapshot.data == 1)
                                    ? Text(
                                        'Streaks : ${snapshot.data.toString()} day',
                                        // style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        'Streaks : ${snapshot.data.toString()} days',
                                        // style: TextStyle(color: Colors.white),
                                      );
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }
                              return Text('??');
                            }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
