import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:haruhabit_app/src/blocs/health_event.dart';
import 'package:haruhabit_app/src/blocs/health_state.dart';
import 'package:haruhabit_app/src/models/health_model.dart';
import 'package:haruhabit_app/src/models/step_model.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_transform/stream_transform.dart';

import '../utils/health_util.dart';

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

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  static final dataTypes = [HealthDataType.STEPS, HealthDataType.WORKOUT];
  final permissions =
      dataTypes.map((e) => HealthDataAccess.READ_WRITE).toList();
  bool isAuthorized = false;
  final _stepFetcher = PublishSubject<StepModel>();
  List<HealthDataPoint> _healthDataList = [];
  static final types = dataTypesIOS;

  Observable<StepModel> get healthData => _stepFetcher.stream;

  Future<void> onHealthFetched(
      HealthFetched event, Emitter<HealthState> emit) async {
    // 불러올 Apple HealthKit Data가 없으면 종료
    print("on health fetch");
    try {
      if (state.status == HealthStatus.initial) {
        print("entered");
        isAuthorized = await authorize();
        if (isAuthorized) {
          final stepData = await _fetchStepData();
          print(stepData.steps);
          _stepFetcher.sink.add(stepData);
          return emit(
              state.copyWith(status: HealthStatus.success, model: stepData));
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

  Future _addWorkoutData(
      HealthWorkoutActivityType type, DateTime start, DateTime end) async {
    bool success = true;
    success &= await health.writeWorkoutData(
      type,
      start,
      end,
    );
    // _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    success ? print('Data Added') : print('Data Not Added');
  }

  // fetch today's step count from the health plugin
  Future<StepModel> _fetchStepData() async {
    // today's data since midnight
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    late StepModel stepModel;

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);
    print(requested);

    if (requested) {
      try {
        stepModel = StepModel(
            steps: await health.getTotalStepsInInterval(midnight, now) as int);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
      print('Total number of steps: ${stepModel.steps}');
    }
    // return healthModel;
    return (stepModel.steps == null)
        ? const StepModel(steps: 0)
        : stepModel;
  }

    /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    // setState(() => _state = AppState.FETCHING_DATA);

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(hours: 24));

    // Clear old data points
    _healthDataList.clear();

    try {
      // fetch health data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(yesterday, now, types);
      print(healthData.length);

      // save all the new data points (only the first 100)
      _healthDataList.addAll(
          (healthData.length < 10) ? healthData : healthData.sublist(0, 10));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

    // print the results
    _healthDataList.forEach((x) => print(x));

    // update the UI to display the results
    // setState(() {
    //   _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    // });
  }


}

final healthBloc = HealthBloc();
