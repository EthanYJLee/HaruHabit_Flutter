class ScheduleModel {
  final int? sId;
  final String? date;
  final String? schedule;
  final String? place;
  final String? hour;
  final String? minute;

  ScheduleModel(
      {this.sId, this.date, this.schedule, this.place, this.hour, this.minute});
  

  ScheduleModel.fromMap(Map<String, dynamic> res)
      : sId = res['sId'],
        date = res['date'],
        schedule = res['schedule'],
        place = res['place'],
        hour = res['hour'],
        minute = res['minute'];

  Map<String, Object?> toMap() {
    return {
      'sId': sId,
      'date': date,
      'schedule': schedule,
      'place': place,
      'hour': hour,
      'minute': minute,
    };
  }
}
