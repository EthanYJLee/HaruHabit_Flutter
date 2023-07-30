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
  const Streak({super.key, required this.hId, required this.day});
  final String hId;
  final DateTime day;

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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late ValueNotifier<DateTime> _focusedDay = ValueNotifier(widget.day);
  // final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  late List<StreakModel> streakModel;
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streakBloc.getStreakLists(widget.hId, widget.day.toString());
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
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/wallpaper.jpg'), // 배경 이미지
          ),
        ),
        height: MediaQuery.of(context).size.height / 2,
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
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            calendarFormat: _calendarFormat,
                            eventLoader: _getStreaksForDay,
                            startingDayOfWeek: StartingDayOfWeek.sunday,
                            calendarStyle: const CalendarStyle(
                              outsideDaysVisible: true,
                              markerDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 138, 128),
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 189, 183),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 138, 128),
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              leftChevronIcon: Icon(
                                CupertinoIcons.arrow_left_circle,
                                // color: Color.fromARGB(255, 164, 158, 255),
                                color: Color.fromARGB(255, 255, 138, 128),
                              ),
                              rightChevronIcon: Icon(
                                CupertinoIcons.arrow_right_circle,
                                // color: Color.fromARGB(255, 164, 158, 255),
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

                // ----------------------------------------------------
                // Expanded(
                //   child: Container(
                //     padding: const EdgeInsets.only(left: 30, right: 30),
                //     child: ValueListenableBuilder<List<Event>>(
                //       valueListenable: _selectedEvents,
                //       builder: (context, value, _) {
                //         /// Desc : 페이지 빌드 후에 addPostFrameCallback()를 통해 비동기로 콜백함수를 호출한다.
                //         /// selected 되어있는 날짜의 Event를 ListView로 보여주기 위한 목적.
                //         WidgetsBinding.instance.addPostFrameCallback((_) {
                //           calendarBloc.getEventLists();
                //           // setState()가 있는 함수 호출
                //           _onDaySelected(_selectedDay!, _focusedDay.value);
                //         });
                //         // value = _selectedEvents로 적용
                //         return ListView.builder(
                //           itemCount: value.length,
                //           itemBuilder: (context, index) {
                //             return Container(
                //               margin: const EdgeInsets.symmetric(
                //                 vertical: 5.0,
                //               ),
                //               decoration: BoxDecoration(
                //                 border: Border.all(),
                //                 borderRadius: BorderRadius.circular(15.0),
                //               ),
                //               child: CheckboxListTile(
                //                 title: Text(
                //                   value[index].schedule,
                //                 ),
                //                 subtitle: Text(
                //                   value[index].place,
                //                 ),
                //                 secondary: Text(
                //                   "${value[index].hour.toString().padLeft(2, "0")}" +
                //                       " : " +
                //                       "${value[index].minute.toString().padLeft(2, "0")}",
                //                 ),
                //                 value: (value[index].isDone == 0) ? false : true,
                //                 // value: false,
                //                 onChanged: (bool? val) {
                //                   setState(() {
                //                     if (val == true) {
                //                       value[index].isDone = 1;
                //                     } else {
                //                       value[index].isDone = 0;
                //                     }
                //                     // 체크박스 체크하면 0, 1 (isDone? false/true) 값 업데이트
                //                     handler.scheduleIsDone(value[index].isDone,
                //                         value[index].sId.toString());
                //                     // 완료 여부 업데이트한 뒤 이벤트리스트 다시 가져와야 함!!!!!!
                //                     calendarBloc.getEventLists();
                //                   });
                //                 },
                //               ),
                //             );
                //           },
                //         );
                //       },
                //     ),
                //   ),
                // ),
                ElevatedButton(
                    onPressed: () {}, child: const Text('achieved today')),
                ElevatedButton(
                    onPressed: () {}, child: const Text('end this habit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
