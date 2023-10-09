import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculate diff b/w two dates', () {
    var today = DateTime.now();
    var startDate = DateTime.parse("2023-07-09");
    var value = today.difference(startDate).inDays;
    // expect(value, 10);
    print(today);
    print(startDate);
    print(value);
  });
}
