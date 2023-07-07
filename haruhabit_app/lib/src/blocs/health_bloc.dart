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
  HealthBloc() : super(const HealthState()) {
    on<HealthFetched>(
      // (event, emit)
      _onHealthFetched,
      // throttle을 사용해 연속된 콜 방지
      transformer: throttleDroppable(const Duration(milliseconds: 100)),
    );
  }

  HealthStatus _state = HealthStatus.initial;
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  static final dataTypes = [HealthDataType.STEPS, HealthDataType.WORKOUT];
  final permissions =
      dataTypes.map((e) => HealthDataAccess.READ_WRITE).toList();
  bool isAuthorized = false;
  // final _stepFetcher = PublishSubject<StepModel>();
  // Observable<StepModel> get healthData => _stepFetcher.stream;
  List<HealthDataPoint> _healthDataList = [];
  static final type = dataTypesIOS;

  // Health View draw 시 "BlocProvider(create: (_) => HealthBloc()..add(HealthFetched()))"
  Future<void> _onHealthFetched(
      HealthFetched event, Emitter<HealthState> emit) async {
    // 불러올 Apple HealthKit Data가 없으면 종료
    print("1. on health fetch");
    print("현재 State: ${state.status}");
    try {
      if (state.status == HealthStatus.initial) {
        print("2. initially entered");
        isAuthorized = await _authorize();
        if (state.status == HealthStatus.authorized) {
          print("3. Authorized");
          final stepData = await _fetchStepData();
          // if (stepData.steps != null) {
          if (state.status == HealthStatus.dataReady) {
            // Step Data 권한 허용했을 경우 (Fetch 성공 시)
            return emit(state.copyWith(
                status: HealthStatus.dataReady, model: stepData));
            // Step Data 권한 허용 안 했을 경우 (Fetch 실패 시)
          } else {
            print("4. Step Data is empty");
            // return emit(state.copyWith(status: HealthStatus.unauthorized));
          }
        }
      }
    } catch (_) {
      emit(state.copyWith(status: HealthStatus.failure));
    }
  }

  // Desc : 접근 권한 여부 결정 (Check whether permission for Apple HealthKit is granted or not)
  Future<bool> _authorize() async {
    // HealthStatus _state = HealthStatus.initial;
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
        authorized
            ? emit(state.copyWith(status: HealthStatus.authorized))
            : emit(state.copyWith(status: HealthStatus.unauthorized));
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

    return authorized;
  }

  // /// Fetch data points from the health plugin and show them in the app.
  // Future fetchHealthData() async {
  //   // define the types to get
  //   final types = [
  //     HealthDataType.HEART_RATE,
  //     HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  //     HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  //     HealthDataType.STEPS,
  //     HealthDataType.ACTIVE_ENERGY_BURNED,
  //   ];

  //   // get data within the last 24 hours
  //   final now = DateTime.now();
  //   final yesterday = now.subtract(const Duration(days: 1));

  //   // requesting access to the data types before reading them
  //   bool requested = await health.requestAuthorization(types);

  //   if (requested) {
  //     try {
  //       // fetch health data
  //       healthData = await health.getHealthDataFromTypes(yesterday, now, types);

  //       if (healthData.isNotEmpty) {
  //         for (HealthDataPoint h in healthData) {
  //           if (h.type == HealthDataType.HEART_RATE) {
  //             heartRate = "${h.value}";
  //           } else if (h.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
  //             bloodPreSys = "${h.value}";
  //           } else if (h.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
  //             bloodPreDia = "${h.value}";
  //           } else if (h.type == HealthDataType.STEPS) {
  //             steps = "${h.value}";
  //           } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
  //             activeEnergy = "${h.value}";
  //           }
  //         }
  //         if (bloodPreSys != "null" && bloodPreDia != "null") {
  //           bp = "$bloodPreSys / $bloodPreDia mmHg";
  //         }

  //         setState(() {});
  //       }
  //     } catch (error) {
  //       print("Exception in getHealthDataFromTypes: $error");
  //     }

  //     // filter out duplicates
  //     healthData = HealthFactory.removeDuplicates(healthData);
  //   } else {
  //     print("Authorization not granted");
  //   }

  // Fetch today's step count from the health plugin
  Future<StepModel> _fetchStepData() async {
    // today's data since midnight
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    late StepModel stepModel;
    int _noOfSteps;

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);
    // bool requested = await health.requestAuthorization([HealthDataType.STEPS, HealthDataType.HEART_RATE, HealthDataType.WORKOUT, HealthDataType.BLOOD_PRESSURE_SYSTOLIC, HealthDataType.BLOOD_PRESSURE_DIASTOLIC, HealthDataType.ACTIVE_ENERGY_BURNED]);

    if (requested) {
      print("4. Accessed to Step Data");
      try {
        stepModel = StepModel(
            steps: await health.getTotalStepsInInterval(midnight, now) as int);
        // print(health.getHealthDataFromTypes(
        //     midnight, now, [HealthDataType.BLOOD_PRESSURE_SYSTOLIC]));
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
      print('5. Total number of steps: ${stepModel.steps}');
      _noOfSteps = (stepModel.steps == null) ? 0 : stepModel.steps;
      (stepModel.steps == null)
          ? emit(state.copyWith(status: HealthStatus.noData))
          : emit(state.copyWith(status: HealthStatus.dataReady));
    } else {
      emit(state.copyWith(status: HealthStatus.unauthorized));
    }
    // return (stepModel.steps == null) ? const StepModel(steps: 0) : stepModel;
    // stepModel.steps == null
    //     ? emit(state.copyWith(status: HealthStatus.unauthorized))
    //     : emit(state.copyWith(status: HealthStatus.stepsReady));
    return stepModel;
  }

  //**
  // --------------------- 1 ---------------------
  // */
  // // write new workout data to Apple Health
  // Future _addWorkoutData(
  //     HealthWorkoutActivityType type, DateTime start, DateTime end) async {
  //   bool success = true;
  //   success &= await health.writeWorkoutData(
  //     type,
  //     start,
  //     end,
  //   );
  //   // _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
  //   success ? print('Data Added') : print('Data Not Added');
  // }

  //**
  // --------------------- 2 ---------------------
  // */
  // // Fetch data points from the health plugin and show them in the app.
  // Future fetchData() async {
  //   // setState(() => _state = AppState.FETCHING_DATA);

  //   // get data within the last 24 hours
  //   final now = DateTime.now();
  //   final yesterday = now.subtract(Duration(hours: 24));

  //   // Clear old data points
  //   _healthDataList.clear();

  //   try {
  //     // fetch health data
  //     List<HealthDataPoint> healthData =
  //         await health.getHealthDataFromTypes(yesterday, now, types);
  //     print(healthData.length);

  //     // save all the new data points (only the first 100)
  //     _healthDataList.addAll(
  //         (healthData.length < 10) ? healthData : healthData.sublist(0, 10));
  //   } catch (error) {
  //     print("Exception in getHealthDataFromTypes: $error");
  //   }

  //   // filter out duplicates
  //   _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

  //   // print the results
  //   _healthDataList.forEach((x) => print(x));

  //   // update the UI to display the results
  //   // setState(() {
  //   //   _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
  //   // });
  // }
}

final healthBloc = HealthBloc();
