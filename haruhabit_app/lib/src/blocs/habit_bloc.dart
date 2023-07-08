import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../models/habit_model.dart';

class HabitBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _allHabitFetcher = PublishSubject<List<HabitModel>>();

  Observable<List<HabitModel>> get allHabit => _allHabitFetcher.stream;

  fetchAllHabits() async{
    List<HabitModel> habitModel = await _handler.queryAllHabits();
    _allHabitFetcher.sink.add(habitModel);
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
