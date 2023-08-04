import 'package:haruhabit_app/src/blocs/streak_bloc.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../models/habit_model.dart';

class HabitBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _allHabitFetcher = PublishSubject<List<HabitModel>>();
  final _habitOnProgressFetcher = PublishSubject<List<HabitModel>>();
  // fetch한 습관들의 각 longest consecutive streaks를 구독할 fetcher
  // final _streakFetcher = PublishSubject<List<int>>();

  Observable<List<HabitModel>> get allHabit => _allHabitFetcher.stream;
  // Observable<List<int>> get longestStreak => _streakFetcher.stream;
  Observable<List<HabitModel>> get habitOnProgress =>
      _habitOnProgressFetcher.stream;

  final _totalDatesFetcher = PublishSubject<int>();
  Observable<int> get totalDates => _totalDatesFetcher.stream;

  final _percentageFetcher = PublishSubject<double>();
  Observable<double> get percentage => _percentageFetcher.stream;


  fetchAllHabits() async {
    List<HabitModel> habitModel = await _handler.queryAllHabits();
    // List<int> streakLists = [];
    // int streak;
    // for (HabitModel h in habitModel) {
    //   // print(h.category.toString());
    //   // print(h.hId);
    //   streak = await _handler.findLongestStreak(h.hId!);
    //   streakLists.add(streak);
    // }
    // _streakFetcher.sink.add(streakLists);
    _allHabitFetcher.sink.add(habitModel);
  }

  fetchSelectedHabit(int hId) async {
    List<HabitModel> model = await _handler.querySelectedHabit(hId);
    // print(model.first.startDate);
    // print(DateTime.now()
    //         .difference(DateTime.parse(model.first.startDate))
    //         .inDays +
    //     1);
    _totalDatesFetcher.sink.add(DateTime.now()
            .difference(DateTime.parse(model.first.startDate))
            .inDays +
        1);
  }

  fetchPercentage(int hId) async {
    Map<DateTime, dynamic> _completed = await _handler.streakLists(hId);
    // print(_completed.length);
    List<HabitModel> _model = await _handler.querySelectedHabit(hId);
    // print(DateTime.now()
    //         .difference(DateTime.parse(_model.first.startDate))
    //         .inDays +
    //     1);
    _percentageFetcher.sink.add(_completed.length/(DateTime.now().difference(DateTime.parse(_model.first.startDate)).inDays+1));
  }

  Future<int> addHabit(String category, String habit, int? spending,
      String? currency, String startDate) async {
    HabitModel habitModel = HabitModel(
      category: category,
      habit: habit,
      spending: spending,
      currency: currency,
      startDate: startDate,
    );
    await _handler.insertHabit(habitModel);
    return 0;
  }

  dispose() {
    _allHabitFetcher.close();
  }
}

final HabitBloc habitBloc = HabitBloc();
