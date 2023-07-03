import 'package:equatable/equatable.dart';

class StepModel extends Equatable {
  const StepModel({required this.steps});

  final int steps;

  @override
  // TODO: implement props
  List<Object> get props => [steps];
}
