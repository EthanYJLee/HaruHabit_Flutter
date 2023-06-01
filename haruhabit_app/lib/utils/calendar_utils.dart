// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:haruhabit_app/models/schedule_model.dart';
import 'package:haruhabit_app/utils/database_handler.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  String schedule;
  String place;
  String hour;
  String minute;

  Event(this.schedule, this.place, this.hour, this.minute);

  @override
  String toString() => schedule;
}

final DatabaseHandler handler = DatabaseHandler();

/// Example events.
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.

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

// final Map<DateTime, dynamic> eventSource = {
//   DateTime(2023, 6, 1): [
//     Event('5분 기도하기', 'd', 'd', 'd'),
//     Event('교회 가서 인증샷 찍기', 'd', 'd', 'd'),
//     Event('QT하기', 'd', 'd', 'd'),
//     Event('셀 모임하기', 'd', 'd', 'd'),
//   ],
//   // DateTime(2023, 6, 2): [
//   //   Event('5분 기도하기'),
//   //   Event('치킨 먹기'),
//   //   Event('QT하기'),
//   //   Event('셀 모임하기'),
//   // ],
// };
// late Map<DateTime, dynamic> eventSource = {};
late LinkedHashMap<DateTime, dynamic> kEvents =
    LinkedHashMap<DateTime, dynamic>();
Map<DateTime, dynamic> eventSource = Map<DateTime, dynamic>();

void getEventLists() async {
  eventSource = await handler.eventLists();
  kEvents = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll(eventSource);
}

int getHashCode(DateTime key) {
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
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day - 7);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day + 7);
