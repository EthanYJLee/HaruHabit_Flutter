// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:table_calendar/table_calendar.dart';

/// Desc : 일정 (Schedule)을 달력에 표시하기 위한 Event 객체 정의
/// Date : 2023.06.02
class Event {
  String sId;
  String schedule;
  String place;
  int hour;
  int minute;
  int isDone;

  Event(
      this.sId, this.schedule, this.place, this.hour, this.minute, this.isDone);

  @override
  String toString() => schedule;
}

class HabitStatus {
  String stId;
  String hId;
  String date;

  HabitStatus(this.stId, this.hId, this.date);

  @override
  String toString() => date;
}

final DatabaseHandler handler = DatabaseHandler();

// /// Example events.
// /// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
// final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
//     key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 50),
//     value: (item) => List.generate(
//         item % 4 + 1, (index) => Event('Event $item | ${index + 1}', true)))
//   ..addAll({
//     kToday: [
//       Event('Today\'s Event 1', true),
//       Event('Today\'s Event 2', false),
//     ],
//   });

// Update : CalendarBloc으로 대체함
// Date : 2023.06.23
// getEventLists() async {
//   // Event들을 날짜별로 묶은 모델 생성
//   eventSource = await handler.eventLists();
//   // Map 객체를 LinkedHashMap 객체로 다시 변형
//   //**
//   // LinkedHashMap: == 비교나 hash 값 불러오는 등의 기능을 사용자 정의할 수 있게 해주는 map임.
//   // addAll(eventSource)는 객체 생성과 동시에 addAll 메소드를 실행하라는 뜻임.
//   // equals 파라미터는 isSameDay 함수 실행으로 equal 여부를 판단하도록 사용자 정의한다는 의미임.
//   // */
//   kEvents = LinkedHashMap(
//     equals: isSameDay,
//     hashCode: getHashCode,
//   )..addAll(eventSource);
// }

int getHashCode(DateTime key) {
  // print(DateTime.now().day * 1000000 +
  //     DateTime.now().month * 10000 +
  //     DateTime.now().year);

  // ddMMyyyy
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 3, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 3, kToday.month, kToday.day);
