import 'package:flutter_test/flutter_test.dart';

void main(){
  test('new Future.value() returns the value', () {
    var value = Future.value(10);
    expect(value, 10);
  });

  test('new Future.value() returns the value', () {
    var value = Future.value(10);
    expect(value, Future.value(10));
  });
  
  test('new Future.value() returns the value with completion', () {
    var value = Future.value(10);
    expect(value, completion(10));
  });
}