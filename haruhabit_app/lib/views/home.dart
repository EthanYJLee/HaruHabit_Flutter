import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/models/schedule_model.dart';
import 'package:haruhabit_app/utils/card_dialog.dart';
import 'package:haruhabit_app/utils/create_habit.dart';
import 'package:haruhabit_app/utils/create_schedule.dart';
import 'package:haruhabit_app/utils/database_handler.dart';
import 'package:haruhabit_app/views/calendar.dart';
import 'package:haruhabit_app/views/history.dart';
import 'package:haruhabit_app/views/tabbar.dart';
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
    // _resetSelectedDate();
    // Database Handler 초기화
    handler = DatabaseHandler();
    // DB 시작
    handler.initializeHabitsDB().whenComplete(() {
      setState(() {});
    });
    handler.initializeSchedulesDB().whenComplete(() {
      setState(() {});
    });
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now().add(const Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        drawer: _drawer(),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   backgroundColor: Colors.redAccent[100],
        //   child: Icon(CupertinoIcons.add),
        // ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _calendarTimeline(),
                // const SizedBox(height: 20),
                // _state != AppState.AUTHORIZED
                //     ? Text(_state.toString())
                //     : Text(_state.toString()),
                _gridCard("오늘 걸음 수", _noOfSteps.toString()),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "To-Do",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     Navigator.of(context)
                      //         .push(CardDialog(builder: (context) {
                      //       return CreateSchedule();
                      //     })).then((_) {
                      //       setState(() {});
                      //     });
                      //   },
                      //   icon: Icon(
                      //     CupertinoIcons.add,
                      //   ),
                      // )
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "View all",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                _gridCard("dd", ""),
                ElevatedButton(
                    onPressed: () {
                      fetchStepData();
                    },
                    child: const Text("fetch step data")),
              ],
            ),
          ),
        ),

        /// Desc : 습관 및 일정을 추가하는 Floating Action Button
        /// Date : 2023.06.01
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SpeedDial(
          backgroundColor: Colors.redAccent[100],
          overlayColor: Colors.black,
          icon: Icons.add,
          activeIcon: Icons.close,
          direction: SpeedDialDirection.up,
          childPadding: const EdgeInsets.all(5),
          spaceBetweenChildren: 4,
          spacing: 3,
          useRotationAnimation: true,
          animationCurve: Curves.easeInOutQuart,
          children: [
            SpeedDialChild(
              child: const Icon(CupertinoIcons.calendar),
              label: "습관 추가",
              labelBackgroundColor: Colors.transparent,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              // onTap: () => showSearchView(),
              onTap: () {
                Navigator.of(context).push(CardDialog(builder: (context) {
                  return const CreateHabit();
                })).then((_) {
                  setState(() {});
                });
              },
            ),
            SpeedDialChild(
                child: const Icon(CupertinoIcons.clock),
                label: "일정 추가",
                labelBackgroundColor: Colors.transparent,
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                // onTap: () => showSortDialog(),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Calendar()));
                }),
            SpeedDialChild(
              child: const Icon(CupertinoIcons.list_bullet),
              label: "목록 보기",
              labelBackgroundColor: Colors.transparent,
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const History()));
              },
            ),
          ],
        ),
      ),
    );
  }
  // ---------------------Functions---------------------

  /// Desc : 애플 건강 접근 권한 여부 확인
  /// Check whether Apple Health Authorization is granted or denied
  /// Date : 2023.05.16
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

  /// Desc : 애플 건강에서 걸음 수 데이터 받기
  /// Fetch Step Data from Appel Health
  /// Date : 2023.05.16
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

  /// Desc: 홈 화면 Drawer Widget
  /// Date: 2023.06.01
  Widget _drawer() {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 100,
            child: DrawerHeader(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              '사용자 설정',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: ListTile(
              title: const Text('회원정보 수정', style: TextStyle(fontSize: 14)),
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              onTap: () {
                print('회원정보 수정');
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: ((context) => )));
              },
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              '기타',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  title: const Text('로그아웃', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    // _logOut(context);
                  },
                ),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  title: const Text('회원탈퇴', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    // _deleteAccount(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Desc : 년, 월, 일 선택할 수 있는 Timeline Widget
  /// Timeline Widget shows year, month, and date
  /// Date : 2023.05.28
  Widget _calendarTimeline() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          decoration: const BoxDecoration(
              // border: Border.all(strokeAlign: BorderSide.strokeAlignOutside),
              // borderRadius: BorderRadius.circular(30),
              ),
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
            dotsColor: const Color(0xFF333A47),
            locale: 'ko',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
                ),
                child: Text(
                  '${DateFormat.yMMMMd('ko').format(DateTime.now())}',
                  style: const TextStyle(
                      color: Color(0xFF333A47), fontWeight: FontWeight.bold),
                ),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
              const Text(
                "You've got ${"0"} tasks today",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Desc : 진행중인 습관, 일정 등을 보여주는 Grid Card View
  /// Basic Grid Card View contains menu, habits on progress, and today's schedule
  /// Date : 2023.05.26
  // Widget _gridCard(String title, String value, dynamic component) {
  Widget _gridCard(String title, String value) {
    return (title != "") || (value != "")
        ? Container(
            height: MediaQuery.of(context).size.height / 4.5,
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
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
                ],
              ),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height / 6,
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                )),
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
          _gridButton(const Icon(CupertinoIcons.add_circled), "습관 만들기",
              const CreateHabit()),
          SizedBox(
            width: MediaQuery.of(context).size.width / 15,
          ),
          _gridButton(const Icon(CupertinoIcons.chart_bar_circle), "운동 기록하기",
              const CreateHabit())
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
                child: const Text("일정없음"))
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
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      onTap: () {
        Navigator.of(context).push(CardDialog(builder: (context) {
          return destination;
        })).then((_) {
          setState(() {});
        });
      },
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(
                height: 10,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
  // -------------------------------------------------
}
