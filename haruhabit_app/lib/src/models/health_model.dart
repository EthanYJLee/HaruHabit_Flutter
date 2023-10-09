import 'package:equatable/equatable.dart';

class HealthModel extends Equatable {
  const HealthModel(
      {required this.steps,
        required this.heartRate,
      // required this.workout,
      required this.bloodPreSys,
      required this.bloodPreDia,
      required this.energyBurned,
      required this.bp});

  final String? steps;
  final String? heartRate;
  // final String? workout;
  final String? bloodPreSys;
  final String? bloodPreDia;
  final String? energyBurned;
  final String? bp;

  @override
  // TODO: implement props
  List<Object?> get props =>
      [heartRate, bloodPreSys, bloodPreDia, energyBurned];
}
