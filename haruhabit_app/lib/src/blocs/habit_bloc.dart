import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../models/habit_model.dart';

class HabitBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _allHabitFetcher = PublishSubject<List<HabitModel>>();

  Future<int> addHabit(String category, String habit, String startDate) async {
    HabitModel habitModel = HabitModel(
      category: category,
      habit: habit,
      startDate: startDate,
    );
    await _handler.insertHabit(habitModel);
    return 0;
  }
}
