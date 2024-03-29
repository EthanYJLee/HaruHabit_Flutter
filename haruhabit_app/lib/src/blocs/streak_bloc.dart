import 'dart:collection';

import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:haruhabit_app/src/views/streak.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/calendar_utils.dart';

class StreakBloc {
  final _streakFetcher = PublishSubject<LinkedHashMap<DateTime, dynamic>>();
  final DatabaseHandler _handler = DatabaseHandler();
  LinkedHashMap<DateTime, dynamic> kStreaks =
      LinkedHashMap<DateTime, dynamic>();
  Map<DateTime, dynamic> eventSource = <DateTime, dynamic>{};
  Observable<LinkedHashMap<DateTime, dynamic>> get streakList =>
      _streakFetcher.stream;

  final _longestStreak = PublishSubject<int>();
  Observable<int> get longestStreak => _longestStreak.stream;

  final _completedFetcher = PublishSubject<int>();
  Map<DateTime,dynamic> completedLists = <DateTime, dynamic>{};
  Observable<int> get totalCompleted => _completedFetcher.stream;

  /// hId (추가한 습관) 별 달성한 일자 받아오기
  getStreakLists(int hId, String date) async {
    // Streak들을 날짜별로 묶은 모델 생성
    eventSource = await _handler.streakLists(hId);
    kStreaks = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventSource);
    // print('length:${eventSource.length}');
    _streakFetcher.sink.add(kStreaks);
  }

  /// 선택한 습관, 날짜의 달성 기록 DB에 추가/제거
  Future<int> achievedTodaysGoal(int hId, String date) async {
    int result = await _handler.achievedTodaysGoal(hId, date);
    return result;
  }

  Future findLongestStreak(int hId) async {
    int streak = await _handler.findLongestStreak(hId);
    _longestStreak.sink.add(streak);
  }

  getCompletedLists(int hId) async{
    completedLists = await _handler.streakLists(hId);
    _completedFetcher.sink.add(completedLists.length);
  }

  // getStreakLists() async {
  //   // Event들을 날짜별로 묶은 모델 생성
  //   // eventSource = await handler.eventLists();
  //   // Map 객체를 LinkedHashMap 객체로 다시 변형
  //   //**
  //   // LinkedHashMap: == 비교나 hash 값 불러오는 등의 기능을 사용자 정의할 수 있게 해주는 map
  //   // addAll(eventSource)는 객체 생성과 동시에 addAll 메소드를 실행하라는 의미
  //   // equals 파라미터는 isSameDay 함수 실행으로 equal 여부를 판단하도록 사용자 정의한다는 의미
  //   // */
  //   kStreaks = LinkedHashMap(
  //     equals: isSameDay,
  //     hashCode: getHashCode,
  //   )..addAll(eventSource);
  //   _eventFetcher.sink.add(kEvents);
  // }
}

final streakBloc = StreakBloc();
