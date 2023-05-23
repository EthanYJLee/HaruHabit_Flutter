class HabitModel {
  final int? id;
  final String title;
  final String category;
  final String content;
  final String startDate;
  final String endDate;

  HabitModel(
      {this.id,
      required this.title,
      required this.category,
      required this.content,
      required this.startDate,
      required this.endDate});

  HabitModel.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        title = res['title'],
        category = res['category'],
        content = res['content'],
        startDate = res['startDate'],
        endDate = res['endDate'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'startDate': startDate,
      'endDate': endDate
    };
  }
}
