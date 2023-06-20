import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/calendar_utils.dart';
import '../utils/database_handler.dart';

class CalendarBloc {
  final _eventFetcher = PublishSubject<LinkedHashMap<DateTime, dynamic>>();

  Observable<LinkedHashMap<DateTime, dynamic>> get eventList =>
      _eventFetcher.stream;

  final DatabaseHandler handler = DatabaseHandler();

  LinkedHashMap<DateTime, dynamic> kEvents = LinkedHashMap<DateTime, dynamic>();
  Map<DateTime, dynamic> eventSource = <DateTime, dynamic>{};

  getEventLists() async {
    // Event들을 날짜별로 묶은 모델 생성
    eventSource = await handler.eventLists();
    print(eventSource.keys);
    print(eventSource.keys.toList());

    // Map 객체를 LinkedHashMap 객체로 다시 변형
    //**
    // LinkedHashMap: == 비교나 hash 값 불러오는 등의 기능을 사용자 정의할 수 있게 해주는 map임.
    // addAll(eventSource)는 객체 생성과 동시에 addAll 메소드를 실행하라는 뜻임.
    // equals 파라미터는 isSameDay 함수 실행으로 equal 여부를 판단하도록 사용자 정의한다는 의미임.
    // */
    kEvents = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventSource);

    _eventFetcher.sink.add(kEvents);
  }
}

final calendarBloc = CalendarBloc();
