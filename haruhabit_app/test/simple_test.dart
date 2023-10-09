import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should be lowercase', () {
    String hello = "Hello World";
    expect(hello.toLowerCase(), "hello world"); // 테스트를 실행했을 때의 기대값과 실제값을 비교합니다.
  });
}
