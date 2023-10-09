class HabitModel {
  final int? hId;
  final String category;
  final String habit;
  final int? spending;
  final String? currency;
  final String startDate;
  final String? endDate;

  HabitModel(
      {this.hId,
      required this.category,
      required this.habit,
      this.spending,
      this.currency,
      required this.startDate,
      this.endDate});

  HabitModel.fromMap(Map<String, dynamic> res)
      : hId = res['hId'],
        category = res['category'],
        habit = res['habit'],
        spending = res['spending'],
        currency = res['currency'],
        startDate = res['startDate'],
        endDate = res['endDate'];

  Map<String, Object?> toMap() {
    return {
      'hId': hId,
      'category': category,
      'habit': habit,
      'spending': spending,
      'currency': currency,
      'startDate': startDate,
      'endDate': endDate
    };
  }
}
