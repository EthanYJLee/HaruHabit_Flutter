class ScheduleModel {
  final int? sId;
  final String? date;
  final String? schedule;
  final String? place;
  // final String? hour;
  // final String? minute;
  final int? hour;
  final int? minute;
  int isDone;

  ScheduleModel(
      {this.sId,
      this.date,
      this.schedule,
      this.place,
      this.hour,
      this.minute,
      required this.isDone});

  ScheduleModel.fromMap(Map<String, dynamic> res)
      : sId = res['sId'],
        date = res['date'],
        schedule = res['schedule'],
        place = res['place'],
        hour = res['hour'],
        minute = res['minute'],
        isDone = res['isDone'];

  Map<String, Object?> toMap() {
    return {
      'sId': sId,
      'date': date,
      'schedule': schedule,
      'place': place,
      'hour': hour,
      'minute' : minute,
      'isDone': isDone,
    };
  }
  // static List<ScheduleModel> getList() {
  //   return <ScheduleModel>[
  //     CheckBoxListTileModel(
  //       title: "Android",
  //       isCheck: true,
  //     ),
      
  //   ];
  // }
}
