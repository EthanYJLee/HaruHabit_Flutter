class ScheduleModel {
  final int? sId;
  final String? schedule;
  final String? date;
  final DateTime? time;

  ScheduleModel({this.sId, this.schedule, this.date, this.time});

  ScheduleModel.fromMap(Map<String, dynamic> res)
      : sId = res['sId'],
        schedule = res['schedule'],
        date = res['res'],
        time = res['time'];

  Map<String, Object?> toMap() {
    return {
      'sId': sId,
      'schedule': schedule,
      'date': date,
      'time': time,
    };
  }
}
