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
}

final ScheduleBloc scheduleBloc = ScheduleBloc();
