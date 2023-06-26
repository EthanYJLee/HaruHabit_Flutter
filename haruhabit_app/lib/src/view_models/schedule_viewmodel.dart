import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';

class ScheduleViewModel {
  Future<int> addSchedule(String date, String schedule, String place,
      String hour, String minute, int isDone) async {
    DatabaseHandler handler = DatabaseHandler();
    ScheduleModel scheduleModel = ScheduleModel(
      date: date,
      schedule: schedule,
      place: place,
      hour: hour,
      minute: minute,
      isDone: isDone,
    );
    await handler.insertSchedule(scheduleModel);
    return 0;
  }

  
}
