import 'package:equatable/equatable.dart';

class HealthModel extends Equatable {
  const HealthModel(
      {required this.heartRate,
      required this.bp,
      required this.steps,
      required this.activeEnergy,
      required this.bloodPreSys,
      required this.bloodPreDia});

  final String heartRate;
  final String bp;
  final String steps;
  final String activeEnergy;
  final String bloodPreSys;
  final String bloodPreDia;

  @override
  // TODO: implement props
  List<Object?> get props =>
      [heartRate, bp, steps, activeEnergy, bloodPreSys, bloodPreDia];
}
