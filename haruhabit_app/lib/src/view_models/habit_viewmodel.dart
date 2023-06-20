import 'package:haruhabit_app/src/models/habit_model.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';

class HabitViewModel {
  Future<int> addHabit(String category, String habit, String startDate) async {
    DatabaseHandler handler = DatabaseHandler();
    HabitModel habitModel = HabitModel(
      category: category,
      habit: habit,
      startDate: startDate,
    );
    await handler.insertHabit(habitModel);
    return 0;
  }
}
