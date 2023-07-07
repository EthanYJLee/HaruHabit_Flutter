import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/calendar_utils.dart';
import 'package:haruhabit_app/src/utils/card_dialog.dart';
import 'package:haruhabit_app/src/utils/add_habit.dart';
import 'package:haruhabit_app/src/utils/add_schedule.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:haruhabit_app/src/views/home.dart';
import 'package:haruhabit_app/src/views/tabbar.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../blocs/schedule_bloc.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  late List<ScheduleModel> scheduleModel;
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  //**  범위를 정해 이벤트를 받아올 경우 사용할 것
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
  //     .toggledOff; // Can be toggled on/off by longpressing a date
  // final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;
  // */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Desc : 날짜별 Event들을 받아서 kEvents에 LinkedHashMap 형식으로 추가 (업데이트)해주기
    // Date : 2023.06.23
    // Update : CalendarBloc 사용으로 수정
    calendarBloc.getEventLists();
    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _onDaySelected(_selectedDay!, _focusedDay.value);
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return calendarBloc.kEvents[day] ?? [];
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
    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  bool get canClearSelection =>
      // _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;
      _selectedDays.isNotEmpty;

  @override
  void dispose() {
    // TODO: implement dispose
    print('events disposed');
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            setState(() {
              _selectedEvents.value = _getEventsForDay(DateTime.now());
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
          IconButton(
              // Schedule 추가하고 돌아오면 일정 리스트 다시 불러오기
              onPressed: () {
                Navigator.of(context).push(CardDialog(builder: (context) {
                  return AddSchedule(selectedDate: _selectedDay!);
                })).whenComplete(() {
                  calendarBloc.getEventLists();
                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                });
              },
              icon: const Icon(CupertinoIcons.add_circled))
        ],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(15)),
                child: StreamBuilder(
                  stream: calendarBloc.eventList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return TableCalendar<Event>(
                        locale: "en",
                        firstDay: kFirstDay,
                        lastDay: kLastDay,
                        focusedDay: _focusedDay.value,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: true,
                          markerDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 138, 128),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 138, 128),
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    /// Desc : 페이지 빌드 후에 addPostFrameCallback()를 통해 비동기로 콜백함수를 호출한다.
                    /// selected 되어있는 날짜의 Event를 ListView로 보여주기 위한 목적.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      calendarBloc.getEventLists();
                      // setState()가 있는 함수 호출
                      _onDaySelected(_selectedDay!, _focusedDay.value);
                    });
                    // value = _selectedEvents로 적용
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              value[index].schedule,
                            ),
                            subtitle: Text(
                              value[index].place,
                            ),
                            secondary: Text(
                              "${value[index].hour.toString().padLeft(2, "0")}" +
                                  " : " +
                                  "${value[index].minute.toString().padLeft(2, "0")}",
                            ),
                            value: (value[index].isDone == 0) ? false : true,
                            // value: false,
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  value[index].isDone = 1;
                                } else {
                                  value[index].isDone = 0;
                                }
                                // 체크박스 체크하면 0, 1 (isDone? false/true) 값 업데이트
                                handler.scheduleIsDone(value[index].isDone,
                                    value[index].sId.toString());
                                // 완료 여부 업데이트한 뒤 이벤트리스트 다시 가져와야 함!!!!!!
                                calendarBloc.getEventLists();
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desc : Calendar Header 커스텀 클래스
/// Date : 2023.06.24
class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
