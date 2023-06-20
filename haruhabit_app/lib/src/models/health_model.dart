
import 'package:equatable/equatable.dart';

class HealthModel extends Equatable{
  final int steps;

  const HealthModel({required this.steps});

  @override
  // TODO: implement props
  List<Object> get props => [steps];

}