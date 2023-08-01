class StreakModel {
  final int? stId;
  final int? hId;
  final String? date;
  StreakModel({this.stId, this.hId, this.date});

  StreakModel.fromMap(Map<String, dynamic> res)
      : stId = res['stId'],
        hId = res['hId'],
        date = res['date'];
}
