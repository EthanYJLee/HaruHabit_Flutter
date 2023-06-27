import 'package:equatable/equatable.dart';
import 'package:sealed_unions/sealed_unions.dart';

// sealed class HealthEvent extends Equatable {
class HealthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class HealthFetched extends HealthEvent {}
