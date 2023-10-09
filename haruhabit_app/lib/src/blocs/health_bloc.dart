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
  static final dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    // HealthDataType.WORKOUT,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED
  ];
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
          final healthData = await _fetchHealthData();
          if (state.status == HealthStatus.dataReady) {
            /// Health Data Fetch 성공 시
            print("4-1. Health Data is Ready");
            return emit(state.copyWith(status: HealthStatus.dataReady));
          } else {
            /// Health Data 전부 비어있을 경우
            print("4-2. Health Data is empty");
            return emit(state.copyWith(status: HealthStatus.noData));
          }
        }
      }
    } catch (_) {
      emit(state.copyWith(status: HealthStatus.failure));
    }
  }

  // Desc : 접근 권한 여부 결정 (Check whether permission for Apple HealthKit is granted or not)
  Future<bool> _authorize() async {
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
        // authorized
        //     ? emit(state.copyWith(status: HealthStatus.authorized))
        //     : emit(state.copyWith(status: HealthStatus.unauthorized));
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
    authorized
        ? emit(state.copyWith(status: HealthStatus.authorized))
        : emit(state.copyWith(status: HealthStatus.unauthorized));
    return authorized;
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future<HealthModel> _fetchHealthData() async {
    /// define the types to get
    /// 접근할 데이터 타입
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED
    ];
    late HealthModel healthModel;
    late double steps = 0;
    late String heartRate = "0";
    late String bloodPreSys = "0";
    late String bloodPreDia = "0";
    // Total Energy Burned 계산 위해 double 사용
    late double activeEnergyBurned = 0;
    late double basalEnergyBurned = 0;
    late double totalEnergyBurned = 0;
    late String bp = "0 / 0 mmHg";
    String? platform;

    // get data within the last 24 hours
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // requesting access to the data types before reading them
    bool requested = await health.requestAuthorization(types);
    List<HealthDataPoint> _healthDataList = [];
    // List<HealthDataPoint> healthData = [];

    if (requested) {
      try {
        // fetch health data
        print("fetching...");
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(midnight, now, types);
        _healthDataList.addAll(healthData);
        //** To join all the step counts from different time ranges (different data sources)
        // Get list of all different data sources
        List<String> sources = [];
        _healthDataList.forEach((element) {
          sources.add(element.sourceId);
        });
        sources = sources.toSet().toList(); // Get unique values only
        // Set up the variables to store steps in
        Map stepCount = {for (String item in sources) '$item': 0};
        Map stepsKnown = {for (String item in sources) '$item': false};
        Map stepsSourceName = {for (String item in sources) '$item': ""};
        // Set up the variables to store active energy burned in
        Map activeEnergyBurnedCount = {for (String item in sources) '$item': 0};
        Map activeEnergyBurnedKnown = {
          for (String item in sources) '$item': false
        };
        Map activeEnergyBurnedSourceName = {
          for (String item in sources) '$item': ""
        };
        // */
        // Set up the variables to store basal energy burned in
        Map basalEnergyBurnedCount = {for (String item in sources) '$item': 0};
        Map basalEnergyBurnedKnown = {
          for (String item in sources) '$item': false
        };
        Map basalEnergyBurnedSourceName = {
          for (String item in sources) '$item': ""
        };
        for (HealthDataPoint h in healthData) {
          if (h.type == HealthDataType.STEPS) {
            stepsKnown[h.sourceId] = true;
            stepCount[h.sourceId] =
                stepCount[h.sourceId] + double.parse("${h.value}");
            stepsSourceName[h.sourceId] = h.sourceName;
            steps = stepCount[h.sourceId];
          } else if (h.type == HealthDataType.HEART_RATE) {
            heartRate = "${h.value}";
          } else if (h.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
            bloodPreSys = "${h.value}".split(".")[0];
          } else if (h.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
            bloodPreDia = "${h.value}".split(".")[0];
          } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeEnergyBurnedKnown[h.sourceId] = true;
            activeEnergyBurnedCount[h.sourceId] =
                activeEnergyBurnedCount[h.sourceId] +
                    double.parse("${h.value}");
            activeEnergyBurnedSourceName[h.sourceId] = h.sourceName;
            // platform = h.platform.name;
            activeEnergyBurned = activeEnergyBurnedCount[h.sourceId];
          } else if (h.type == HealthDataType.BASAL_ENERGY_BURNED) {
            basalEnergyBurnedKnown[h.sourceId] = true;
            basalEnergyBurnedCount[h.sourceId] =
                basalEnergyBurnedCount[h.sourceId] + double.parse("${h.value}");
            basalEnergyBurnedSourceName[h.sourceId] = h.sourceName;
            // platform = h.platform.name;
            basalEnergyBurned = basalEnergyBurnedCount[h.sourceId];
          }
          totalEnergyBurned = activeEnergyBurned + basalEnergyBurned;
        }
        if (bloodPreSys != "0" && bloodPreDia != "0") {
          bp = "$bloodPreSys / $bloodPreDia mmHg";
        }
        print(bp);
        healthModel = HealthModel(
            steps: steps.toString(),
            heartRate: heartRate,
            bloodPreSys: bloodPreSys,
            bloodPreDia: bloodPreDia,
            energyBurned: totalEnergyBurned.toInt().toString(),
            bp: bp);
        print(healthModel.bp);
        emit(
            state.copyWith(status: HealthStatus.dataReady, model: healthModel));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }
      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
    } else {
      emit(state.copyWith(status: HealthStatus.unauthorized));
      print("Authorization not granted");
    }
    return healthModel;
  }

  /// write new workout data to Apple Health
  /// 저장할 위치 (Health or 기기 내 (SQlite)) 결정할 것
  /// 2023.08.07
  Future _addWorkoutData(
      HealthWorkoutActivityType type, DateTime start, DateTime end) async {
    bool success = true;
    success &= await health.writeWorkoutData(
      type,
      start,
      end,
    );
    // _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    // success
    //     ? emit(state.copyWith(status: HealthStatus.success))
    //     : emit(state.copyWith(status: HealthStatus.failure));
    success ? print('Data Added') : print('Data Not Added');
  }
}

final healthBloc = HealthBloc();
