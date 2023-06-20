import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:rxdart/rxdart.dart';

class ScheduleBloc {
  final DatabaseHandler _handler = DatabaseHandler();
  final _scheduleFetcher = PublishSubject<List<ScheduleModel>>();

  Observable<List<ScheduleModel>> get allSchedule => _scheduleFetcher.stream;

  fetchAllSchedules() async {
    List<ScheduleModel> scheduleModel = await _handler.querySchedules();
    _scheduleFetcher.sink.add(scheduleModel);
  }
}

final ScheduleBloc scheduleBloc = ScheduleBloc();
