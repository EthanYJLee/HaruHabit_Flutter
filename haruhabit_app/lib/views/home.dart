import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/models/schedule_model.dart';
import 'package:haruhabit_app/utils/card_dialog.dart';
import 'package:haruhabit_app/utils/create_habit.dart';
import 'package:haruhabit_app/utils/create_schedule.dart';
import 'package:haruhabit_app/utils/database_handler.dart';
import 'package:health/health.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
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

class _HomeState extends State<Home> {
  /// Desc : Apple Health 관련
  /// Date : 2023.05.15
  List<HealthDataPoint> _healthDataList = [];
  late AppState _state = AppState.DATA_NOT_FETCHED;
  // 접근 권한 범위 (Read, Write)
  final permissions =
      dataTypes.map((e) => HealthDataAccess.READ_WRITE).toList();
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  int _noOfSteps = 0;
  // 접근 권한 요청할 Data Type (걸음 수)
  // static final dataTypes = [HealthDataType.STEPS];
  static final dataTypes = [HealthDataType.STEPS, HealthDataType.WORKOUT];

  /// Desc : Calendar Timeline 관련
  /// Date : 2023.05.26
  late DateTime _selectedDate;

  /// Desc : Schedule (To Do) 관련
  /// Date : 2023.05.26
  late List _schedules = [];
  ScheduleModel _scheduleModel = ScheduleModel();

  /// Desc : DB (SQLite)
  /// Date : 2023.05.28
  late DatabaseHandler handler;

  // -------------------------------------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authorize().then((_) => fetchStepData());
    _resetSelectedDate();
    handler = DatabaseHandler();
    handler.initializeHabitsDB().whenComplete(() {
      setState(() {});
    });
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now().add(const Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {},
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  _calendarTimeline(),
                  // const SizedBox(height: 20),
                  // _state != AppState.AUTHORIZED
                  //     ? Text(_state.toString())
                  //     : Text(_state.toString()),
                  _gridCard("오늘 걸음 수", _noOfSteps.toString(), createArea()),
                  _gridCard("", "", toDoArea()),
                  ElevatedButton(
                      onPressed: () {
                        fetchStepData();
                      },
                      child: const Text("fetch step data"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ---------------------Functions---------------------

  /// Desc : Check whether Apple Health Authorization is granted or denied
  /// Date : 2023-05-16
  Future authorize() async {
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

    setState(() => _state =
        (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
  }

  // /// Add some random health data.
  // Future addData() async {
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

  /// Desc : Fetch Step Data from Appel Health
  /// Date : 2023-05-16
  Future fetchStepData() async {
    setState(() => _state = AppState.FETCHING_DATA);
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);
    print(requested);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      setState(() {
        _noOfSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted - error in authorization");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  // -------------------------------------------------

  // ---------------------Widgets---------------------

  /// Desc : Timeline widget shows date
  /// Date : 2023.05.28
  Widget _calendarTimeline() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: CalendarTimeline(
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateSelected: (date) => print(date),
            leftMargin: 20,
            monthColor: Colors.blueGrey,
            dayColor: Colors.black,
            activeDayColor: Colors.white,
            activeBackgroundDayColor: Colors.redAccent[100],
            dotsColor: Color(0xFF333A47),
            locale: 'ko',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
                ),
                child: Text(
                  '${DateFormat.yMMMMd('ko').format(DateTime.now())}',
                  style: TextStyle(color: Color(0xFF333A47)),
                ),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
              Text("You've got ${"0"} tasks today"),
            ],
          ),
        ),
      ],
    );
  }

  /// Desc : Basic Grid Card View contains menu, habits on progress, and today's schedule
  /// Date : 2023.05.26
  Widget _gridCard(String title, String value, dynamic component) {
    return Container(
      height: MediaQuery.of(context).size.height / 4.5,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            component,
          ],
        ),
      ),
    );
  }

  /// Desc : First Grid Buttons
  /// Home View 최상단에 보여지는 Grid Button (습관 만들기, 운동 기록 등)
  /// Date : 2023.05.26
  Widget createArea() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _gridButton(
              Icon(CupertinoIcons.add_circled), "습관 만들기", CreateHabit()),
          SizedBox(
            width: MediaQuery.of(context).size.width / 15,
          ),
          _gridButton(
              Icon(CupertinoIcons.chart_bar_circle), "운동 기록하기", CreateHabit())
        ],
      ),
    );
  }

  /// Desc : Second Grid Buttons
  /// 오늘 일정 있을 시 보여주고, 없으면 추가하기 버튼
  /// Date : 2023.05.26
  Widget toDoArea() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: (_schedules.isEmpty)
            ? Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.5,
                // width: MediaQuery.of(context).size.width / 2,
                child: _gridButton(const Icon(CupertinoIcons.add_circled),
                    "추가하기", CreateSchedule()))
            : ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 100,
                    width: 100,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () async {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _schedules[index]['schedule'],
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
      )
    ]);
  }

  Widget _gridButton(Icon icon, String text, dynamic destination) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      onTap: () {
        Navigator.of(context).push(CardDialog(builder: (context) {
          return destination;
        })).then((_) {
          setState(() {});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon, Text(text)],
          ),
        ),
      ),
    );
  }
  // -------------------------------------------------
}
