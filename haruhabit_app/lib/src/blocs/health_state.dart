import 'package:equatable/equatable.dart';
import 'package:haruhabit_app/src/models/health_model.dart';
import 'package:haruhabit_app/src/models/step_model.dart';

// 초기 status 설정
// enum AppState {
//   DATA_NOT_FETCHED,
//   FETCHING_DATA,
//   DATA_READY,
//   NO_DATA,
//   AUTHORIZED,
//   AUTH_NOT_GRANTED,
//   DATA_ADDED,
//   DATA_DELETED,
//   DATA_NOT_ADDED,
//   DATA_NOT_DELETED,
//   STEPS_READY
// }
enum HealthStatus { initial, success, failure }

class HealthState extends Equatable {
  const HealthState({
    this.status = HealthStatus.initial,
    this.model = const StepModel(steps: 0),
  });

  final HealthStatus status;
  final StepModel model;

  HealthState copyWith({HealthStatus? status, StepModel? model}) {
    return HealthState(
      status: status ?? this.status,
      model: model ?? this.model,
    );
  }

  // Equatable로 감지할 state를 props에 담아주기
  @override
  // TODO: implement props
  List<Object> get props => [status, model];
}
