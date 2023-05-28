import 'package:haruhabit_app/models/habit_model.dart';
import 'package:haruhabit_app/utils/database_handler.dart';

class HabitViewModel {
  Future<int> addStudents(
      String category, String habit, String startDate) async {
    DatabaseHandler handler = DatabaseHandler();
    HabitModel habitModel =
        HabitModel(category: category, habit: habit, startDate: startDate);
    await handler.addHabit(habitModel);
    return 0;
  }
}
