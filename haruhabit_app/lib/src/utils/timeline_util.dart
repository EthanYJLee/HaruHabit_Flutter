import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:intl/intl.dart';

class TimelineUtil extends StatefulWidget {
  const TimelineUtil({super.key});

  @override
  State<TimelineUtil> createState() => _TimelineUtilState();
}

class _TimelineUtilState extends State<TimelineUtil> {
  late DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    scheduleBloc
        .fetchSelectedSchedules(_selectedDate.toString().substring(0, 10));
    return Container(
      child: Column(
        children: [
          _timeline(),
          StreamBuilder(
              stream: scheduleBloc.selectedSchedule,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // print(_selectedDate.toString().substring(0, 10));
                  // print(snapshot.data!.length);
                  return _todoSummary(snapshot.data!.length);
                } else if (!snapshot.hasData) {
                  return _todoSummary(0);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error.toString()}');
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ],
      ),
    );
  }

  void _resetSelectedDate() {
    // _selectedDate = DateTime.now().add(const Duration(days: 2));
    _selectedDate = DateTime.now();
  }

  Widget _timeline() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: const BoxDecoration(),
      child: CalendarTimeline(
        // shrink: true,
        // showYears: true,
        initialDate: _selectedDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        // onDateSelected: (date) => print(date),
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        leftMargin: 20,
        monthColor: Colors.blueGrey,
        dayColor: Colors.black,
        activeDayColor: Colors.white,
        activeBackgroundDayColor: Colors.redAccent[100],
        dotsColor: const Color(0xFF333A47),
        // locale: 'ko',
        locale: 'en',
      ),
    );
  }

  /// Desc : 선택한 날짜 / 오늘 및 해당하는 날짜의 일정 개수 보여주기
  /// Date : 2023.06.20
  Widget _todoSummary(int todo) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
            ),
            child: Text(
              // '${DateFormat.yMMMMd('ko').format(DateTime.now())}',
              '${DateFormat.yMMMd('en').format(_selectedDate)}',
              style: const TextStyle(
                  color: Color(0xFF333A47), fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              //-
            },
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                  color: Color(0xFF333A47), fontWeight: FontWeight.bold),
            ),
            onPressed: () => setState(() => _resetSelectedDate()),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "${todo} Schedules",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
