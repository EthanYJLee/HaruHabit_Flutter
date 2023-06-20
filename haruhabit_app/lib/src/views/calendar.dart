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
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;

  // Calendar 관련
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
  //     .toggledOff; // Can be toggled on/off by longpressing a date
  // final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;
  late List<ScheduleModel> scheduleModel;
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    // TODO: implement initState
    getEventLists();
    super.initState();
    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _onDaySelected(_selectedDay!, _focusedDay.value);
    print(_selectedEvents);
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   // Implementation example
  //   final days = daysInRange(start, end);
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        // _rangeStart = null; // Important to clean those
        // _rangeEnd = null;
        // _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   setState(() {
  //     if (_selectedDays.contains(selectedDay)) {
  //       _selectedDays.remove(selectedDay);
  //     } else {
  //       _selectedDays.add(selectedDay);
  //     }

  //     _focusedDay = focusedDay;
  //     // _rangeStart = null;
  //     // _rangeEnd = null;
  //     // _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //   });

  //   _selectedEvents.value = _getEventsForDays(_selectedDays);
  // }

  // void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     _selectedDay = null;
  //     _focusedDay = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });

  //   // `start` or `end` could be null
  //   if (start != null && end != null) {
  //     _selectedEvents.value = _getEventsForRange(start, end);
  //   } else if (start != null) {
  //     _selectedEvents.value = _getEventsForDay(start);
  //   } else if (end != null) {
  //     _selectedEvents.value = _getEventsForDay(end);
  //   }
  // }

  bool get canClearSelection =>
      // _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;
      _selectedDays.isNotEmpty;

  @override
  void dispose() {
    // TODO: implement dispose
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(CardDialog(builder: (context) {
                  return AddSchedule(selectedDate: _selectedDay!);
                })).whenComplete(() => _getEventsForDay(_selectedDay!));
              },
              icon: Icon(CupertinoIcons.add_circled))
        ],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(15)),
                child: TableCalendar<Event>(
                  locale: "en",
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay.value,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  // rangeStartDay: _rangeStart,
                  // rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  // rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  calendarStyle: const CalendarStyle(
                    // Use `CalendarStyle` to customize the UI
                    outsideDaysVisible: true,
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      CupertinoIcons.arrow_left_circle,
                      color: Color.fromARGB(255, 164, 158, 255),
                    ),
                    rightChevronIcon: Icon(
                      CupertinoIcons.arrow_right_circle,
                      color: Color.fromARGB(255, 164, 158, 255),
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                  // onRangeSelected: _onRangeSelected,
                  onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
                ),
              ),
            ),

            // ----------------------------------------------------
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          onTap: () => print('${value[index]}'),
                          title: Text('${value[index]}'),
                          subtitle: Text("${value[index].place}"),
                          trailing: Text(
                              "${value[index].hour} : ${value[index].minute}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
