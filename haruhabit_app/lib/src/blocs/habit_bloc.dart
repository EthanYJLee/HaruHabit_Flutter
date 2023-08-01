import 'package:haruhabit_app/src/blocs/streak_bloc.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../models/habit_model.dart';

class HabitBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _allHabitFetcher = PublishSubject<List<HabitModel>>();
  final _habitOnProgressFetcher = PublishSubject<List<HabitModel>>();
  // fetch한 습관들의 각 longest consecutive streaks를 구독할 fetcher
  final _streakFetcher = PublishSubject<List<int>>();

  Observable<List<HabitModel>> get allHabit => _allHabitFetcher.stream;
  Observable<List<HabitModel>> get habitOnProgress =>
      _habitOnProgressFetcher.stream;
  Observable<List<int>> get longestStreak => _streakFetcher.stream;

  fetchAllHabits() async {
    List<HabitModel> habitModel = await _handler.queryAllHabits();
    List<int> streakLists = [];
    int s;
    for (HabitModel h in habitModel) {
      // print(h.category.toString());
      // print(h.hId);
      s = await _handler.findLongestStreak(h.hId!);
      streakLists.add(s);
    }
    _streakFetcher.sink.add(streakLists);
    _allHabitFetcher.sink.add(habitModel);
  }

  // fetchHabitsOnProgress(String today) async {
  //   List<HabitModel> _model = await _handler.queryHabitsOnProgress(today);
  //   _habitOnProgressFetcher.sink.add(_model);
  // }

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
