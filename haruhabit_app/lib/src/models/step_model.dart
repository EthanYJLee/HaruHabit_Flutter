import 'package:equatable/equatable.dart';

class StepModel extends Equatable {
  final int steps;

  const StepModel({required this.steps});

  @override
  // TODO: implement props
  List<Object> get props => [steps];
}
