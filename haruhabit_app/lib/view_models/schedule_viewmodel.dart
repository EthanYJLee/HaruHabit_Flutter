import 'package:haruhabit_app/models/schedule_model.dart';
import 'package:haruhabit_app/utils/database_handler.dart';

class ScheduleViewModel {
  Future<int> addSchedule(String date, String schedule, String place,
      String hour, String minute) async {
    DatabaseHandler handler = DatabaseHandler();
    ScheduleModel scheduleModel = ScheduleModel(
      date: date,
      schedule: schedule,
      place: place,
      hour: hour,
      minute: minute,
    );
    await handler.insertSchedule(scheduleModel);
    return 0;
  }

  
}
