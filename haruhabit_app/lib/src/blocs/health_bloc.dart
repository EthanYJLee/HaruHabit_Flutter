import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:haruhabit_app/src/blocs/health_event.dart';
import 'package:haruhabit_app/src/blocs/health_state.dart';
import 'package:haruhabit_app/src/models/health_model.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_transform/stream_transform.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  // HealthBloc(super.initialState);
  HealthBloc() : super(const HealthState()) {
    on<HealthFetched>(
      onHealthFetched,
      //throttle을 사용해 연속된 api콜 방지
      transformer: throttleDroppable(const Duration(milliseconds: 100)),
    );
  }

  // List<HealthDataPoint> _healthDataList = [];
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  static final dataTypes = [HealthDataType.STEPS, HealthDataType.WORKOUT];
  final permissions =
      dataTypes.map((e) => HealthDataAccess.READ_WRITE).toList();
  bool isAuthorized = false;
  final _healthFetcher = PublishSubject<HealthModel>();

  Observable<HealthModel> get healthData => _healthFetcher.stream;

  Future<void> onHealthFetched(
      HealthFetched event, Emitter<HealthState> emit) async {
    // 불러올 Apple HealthKit Data가 없으면 종료
    print("on health fetch");
    try {
      if (state.status == HealthStatus.initial) {
        print("entered");
        isAuthorized = await authorize();
        if (isAuthorized) {
          final healthData = await _fetchHealthData();
          print(healthData.steps);
          _healthFetcher.sink.add(healthData);
          return emit(
              state.copyWith(status: HealthStatus.success, model: healthData));
        }
      }
    } catch (_) {
      emit(state.copyWith(status: HealthStatus.failure));
    }
  }

  // Desc : Check whether permission for Apple HealthKit is granted or not

  Future<bool> authorize() async {
    // Permission
    await Permission.activityRecognition.request();
    await Permission.location.request();
    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(dataTypes, permissions: permissions);
    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized = await health.requestAuthorization(dataTypes,
            permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
    authorized ? print("authorized") : print("unauthorized");
    return authorized;
  }

  // /// Add some random health data.
  // Future _addData() async {
  //   final now = DateTime.now();
  //   final earlier = now.subtract(Duration(minutes: 20));
  //   // Add data for supported types
  //   // NOTE: These are only the ones supported on Androids new API Health Connect.
  //   // Both Android's Google Fit and iOS' HealthKit have more types that we support in the enum list [HealthDataType]
  //   // Add more - like AUDIOGRAM, HEADACHE_SEVERE etc. to try them.
  //   bool success = true;
  //   // 걸음 수 Data 추가
  //   success &=
  //       await health.writeHealthData(90, HealthDataType.STEPS, earlier, now);

  //   setState(() {
  //     _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
  //   });
  // }

  Future<HealthModel> _fetchHealthData() async {
    // today's data since midnight
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    late HealthModel healthModel;

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);
    print(requested);

    if (requested) {
      try {
        healthModel = HealthModel(
            steps: await health.getTotalStepsInInterval(midnight, now) as int);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
      print('Total number of steps: ${healthModel.steps}');
    }
    // return healthModel;
    return (healthModel.steps == null)
        ? const HealthModel(steps: 0)
        : healthModel;
  }
}

final healthBloc = HealthBloc();
