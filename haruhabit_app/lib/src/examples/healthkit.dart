import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthKit extends StatefulWidget {
  const HealthKit({super.key});

  @override
  State<HealthKit> createState() => _HealthKitState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}

class _HealthKitState extends State<HealthKit> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 0;

  // Define the types to get.
  // NOTE: These are only the ones supported on Androids new API Health Connect.
  // Both Android's Google Fit and iOS' HealthKit have more types that we support in the enum list [HealthDataType]
  // Add more - like AUDIOGRAM, HEADACHE_SEVERE etc. to try them.
  // static final types = dataTypesAndroid;
  // static final types = dataTypesIOS;
  // Or selected types
  static final types = [
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WORKOUT,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    // Uncomment these lines on iOS - only available on iOS
    HealthDataType.AUDIOGRAM
  ];

  // with coresponsing permissions
  // READ only
  // final permissions = types.map((e) => HealthDataAccess.READ).toList();
  // Or READ and WRITE
  final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  // ---------------------Functions---------------------
  Future authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

    setState(() => _state =
        (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

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
    // _healthDataList.forEach((x) => print(x));

    // update the UI to display the results
    setState(() {
      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    });
  }

  /// Add some random health data.
  Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));

    // Add data for supported types
    // NOTE: These are only the ones supported on Androids new API Health Connect.
    // Both Android's Google Fit and iOS' HealthKit have more types that we support in the enum list [HealthDataType]
    // Add more - like AUDIOGRAM, HEADACHE_SEVERE etc. to try them.
    bool success = true;
    success &= await health.writeHealthData(
        10, HealthDataType.BODY_FAT_PERCENTAGE, earlier, now);
    success &= await health.writeHealthData(
        1.925, HealthDataType.HEIGHT, earlier, now);
    success &=
        await health.writeHealthData(90, HealthDataType.WEIGHT, earlier, now);
    success &= await health.writeHealthData(
        90, HealthDataType.HEART_RATE, earlier, now);
    success &=
        await health.writeHealthData(90, HealthDataType.STEPS, earlier, now);
    success &= await health.writeHealthData(
        200, HealthDataType.ACTIVE_ENERGY_BURNED, earlier, now);
    success &= await health.writeHealthData(
        70, HealthDataType.HEART_RATE, earlier, now);
    success &= await health.writeHealthData(
        37, HealthDataType.BODY_TEMPERATURE, earlier, now);
    success &= await health.writeBloodOxygen(98, earlier, now, flowRate: 1.0);
    success &= await health.writeHealthData(
        105, HealthDataType.BLOOD_GLUCOSE, earlier, now);
    success &=
        await health.writeHealthData(1.8, HealthDataType.WATER, earlier, now);
    success &= await health.writeWorkoutData(
        HealthWorkoutActivityType.AMERICAN_FOOTBALL,
        now.subtract(Duration(minutes: 15)),
        now,
        totalDistance: 2430,
        totalEnergyBurned: 400);
    success &= await health.writeBloodPressure(90, 80, earlier, now);

    // Store an Audiogram
    // Uncomment these on iOS - only available on iOS
    const frequencies = [125.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0];
    const leftEarSensitivities = [49.0, 54.0, 89.0, 52.0, 77.0, 35.0];
    const rightEarSensitivities = [76.0, 66.0, 90.0, 22.0, 85.0, 44.5];

    success &= await health.writeAudiogram(
      frequencies,
      leftEarSensitivities,
      rightEarSensitivities,
      now,
      now,
      metadata: {
        "HKExternalUUID": "uniqueID",
        "HKDeviceName": "bluetooth headphone",
      },
    );

    setState(() {
      _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
    });
  }

  /// Delete some random health data.
  Future deleteData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(hours: 24));

    bool success = true;
    for (HealthDataType type in types) {
      success &= await health.delete(type, earlier, now);
      print(success);
    }

    setState(() {
      _state = success ? AppState.DATA_DELETED : AppState.DATA_NOT_DELETED;
    });
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        _nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future revokeAccess() async {
    try {
      await health.revokePermissions();
    } catch (error) {
      print("Caught exception in revokeAccess: $error");
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          if (p.value is AudiogramHealthValue) {
            // Container(
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(style: BorderStyle.solid, width: 1)),
            //   child: ListTile(
            //     title: Text("${p.typeString}: ${p.value}"),
            //     // trailing: Text('${p.unitString}'),
            //     subtitle: Text(
            //         '${DateFormat.yMMMd().format(p.dateFrom)} - ${DateFormat.yMMMd().format(p.dateTo)}'),
            //   ),
            // );
            return null;
          }
          if (p.value is WorkoutHealthValue) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(style: BorderStyle.solid, width: 1)),
              child: ListTile(
                title: Text(
                    "${p.typeString}: ${(p.value as WorkoutHealthValue).totalEnergyBurned} ${(p.value as WorkoutHealthValue).totalEnergyBurnedUnit?.name}"),
                trailing: Text(
                    '${(p.value as WorkoutHealthValue).workoutActivityType.name}'),
                subtitle: Text(
                    '${DateFormat.yMMMd().format(p.dateFrom)} - ${DateFormat.yMMMd().format(p.dateTo)}'),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(style: BorderStyle.solid, width: 1)),
            child: ListTile(
              title: Text("${p.typeString}: ${p.value}"),
              // trailing: Text('${p.unitString}'),
              subtitle: Text(
                  '${DateFormat.yMMMd().format(p.dateFrom)} - ${DateFormat.yMMMd().format(p.dateTo)}'),
            ),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Column(
      children: [
        Text('Press the download button to fetch data.'),
        Text('Press the plus button to insert some random data.'),
        Text('Press the walking button to get total step count.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorized() {
    return Text('Authorization granted!');
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('Data points inserted successfully!');
  }

  Widget _dataDeleted() {
    return Text('Data points deleted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $_nofSteps');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Widget _dataNotDeleted() {
    return Text('Failed to delete data');
  }

  Widget _content() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTHORIZED)
      return _authorized();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();
    else if (_state == AppState.DATA_ADDED)
      return _dataAdded();
    else if (_state == AppState.DATA_DELETED)
      return _dataDeleted();
    else if (_state == AppState.STEPS_READY)
      return _stepsFetched();
    else if (_state == AppState.DATA_NOT_ADDED)
      return _dataNotAdded();
    else if (_state == AppState.DATA_NOT_DELETED)
      return _dataNotDeleted();
    else
      return _contentNotFetched();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: [
                TextButton(
                    onPressed: authorize,
                    child: Text("Auth", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
                TextButton(
                    onPressed: fetchData,
                    child: Text("Fetch Data",
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
                TextButton(
                    onPressed: addData,
                    child:
                        Text("Add Data", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
                TextButton(
                    onPressed: deleteData,
                    child: Text("Delete Data",
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
                TextButton(
                    onPressed: fetchStepData,
                    child: Text("Fetch Step Data",
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
                // TextButton(
                //     onPressed: revokeAccess,
                //     child: Text("Revoke Access",
                //         style: TextStyle(color: Colors.white)),
                //     style: ButtonStyle(
                //         backgroundColor:
                //             MaterialStatePropertyAll(Colors.blue))),
                TextButton(
                    onPressed: fetchStepData,
                    child: Text("Fetch Step Data",
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue))),
              ],
            ),
            Divider(thickness: 3),
            Expanded(child: Center(child: _content()))
          ],
        ),
      ),
    );
  }
}
