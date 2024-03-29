import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

class ScheduleBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _allScheduleFetcher = PublishSubject<List<ScheduleModel>>();
  final _selectedScheduleFetcher = PublishSubject<List<ScheduleModel>>();

  Observable<List<ScheduleModel>> get allSchedule => _allScheduleFetcher.stream;
  Observable<List<ScheduleModel>> get selectedSchedule =>
      _selectedScheduleFetcher.stream;

  fetchAllSchedules() async {
    List<ScheduleModel> scheduleModel = await _handler.queryAllSchedules();
    _allScheduleFetcher.sink.add(scheduleModel);
  }

  fetchSelectedSchedules(String selectedDate) async {
    List<ScheduleModel> scheduleModel =
        await _handler.querySelectedSchedules(selectedDate);
    _selectedScheduleFetcher.sink.add(scheduleModel);
  }

  Future<int> addSchedule(String date, String schedule, String place, int hour,
      int minute, int isDone) async {
    ScheduleModel scheduleModel = ScheduleModel(
      date: date,
      schedule: schedule,
      place: place,
      hour: hour,
      minute: minute,
      isDone: isDone,
    );
    await _handler.insertSchedule(scheduleModel);
    return 0;
  }

  Future<int> scheduleIsDone(int isChecked, String sId) async{
    int result = await _handler.scheduleIsDone(isChecked, sId);
    return result;
  }

  dispose() {
    _allScheduleFetcher.close();
    _selectedScheduleFetcher.close();
  }
}

final ScheduleBloc scheduleBloc = ScheduleBloc();
