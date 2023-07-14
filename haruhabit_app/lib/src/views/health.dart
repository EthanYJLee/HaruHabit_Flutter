import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:haruhabit_app/src/blocs/health_bloc.dart';
import 'package:haruhabit_app/src/blocs/health_event.dart';
import 'package:haruhabit_app/src/blocs/health_state.dart';
import 'package:haruhabit_app/src/utils/add_health.dart';
import 'package:haruhabit_app/src/utils/card_dialog.dart';
import 'package:haruhabit_app/src/utils/gridcard_util.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:path/path.dart';

import 'history_tabbar.dart';

class Health extends StatelessWidget {
  const Health({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 30, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Health',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          // Navigator.of(context)
                          //     .push(MaterialPageRoute(
                          //         builder: (context) =>
                          //             const HistoryTabbar(initialView: 1)))
                          //     .whenComplete(() {
                          //   scheduleBloc.fetchSelectedSchedules(
                          //       DateTime.now().toString().substring(0, 10));
                          // });
                        },
                        icon: const Icon(CupertinoIcons.right_chevron))
                  ],
                ),
              ),
              BlocProvider(
                // 새로운 BLoC을 만들고 Fetch Event를 add 해준다.
                create: (_) => HealthBloc()..add(HealthFetched()),
                child: BlocBuilder<HealthBloc, HealthState>(
                  // buildWhen: (previous, current) =>
                  //     (previous != current) &&
                  //     current.status == HealthStatus.success,
                  //     /// return true/false to determine whether or not
                  //     /// to rebuild the widget with state

                  builder: (context, state) {
                    // 오류 발생 시
                    switch (state.status) {
                      case HealthStatus.failure:
                        return const Center(
                          child: Text(
                            'failed to fetch posts',
                          ),
                        );

                      case HealthStatus.authorized:
                        // return const Center(
                        //   child: Text(
                        //     'Authorized',
                        //   ),
                        // );
                        return const Center(
                          child: CircularProgressIndicator(),
                        );

                      /// 걸음 수 데이터 접근 권한 없을 경우
                      case HealthStatus.unauthorized:
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                padding:
                                    const EdgeInsets.only(top: 50, bottom: 50),
                                child: const Text(
                                  "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your health data",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                        );
                      case HealthStatus.noData:
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                padding:
                                    const EdgeInsets.only(top: 50, bottom: 50),
                                child: const Text(
                                  "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your health data",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                        );

                      case HealthStatus.success:
                        return const Center(child: Text("success"));

                      /// 걸음 수 데이터 접근 권한 허용 후
                      case HealthStatus.dataReady:
                        if (state.props.isEmpty) {
                          return const Center(
                            child: Text(
                              'no data',
                            ),
                          );
                        }
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: healthCard(context,
                                            title: 'Step Count',
                                            data: state.model.steps
                                                    .toString()
                                                    .split('.')[0] +
                                                " steps",
                                            image:
                                                "assets/images/footprint.png")),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: healthCard(context,
                                            title: 'Heart Rate',
                                            data: state.model.heartRate
                                                    .toString()
                                                    .split('.')[0] +
                                                " BPM",
                                            image:
                                                "assets/images/heart-attack.png")),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: healthCard(context,
                                            title: 'Blood Pressure',
                                            data: state.model.bp
                                                .toString()
                                                .split('.')[0],
                                            image:
                                                "assets/images/blood-pressure.png")),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: healthCard(context,
                                            title: 'Energy Burned',
                                            data: state.model.energyBurned
                                                    .toString()
                                                    .split('.')[0] +
                                                " cal",
                                            image:
                                                "assets/images/calories.png")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      case HealthStatus.initial:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.only(left: 30, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workout',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          // Navigator.of(context)
                          //     .push(MaterialPageRoute(
                          //         builder: (context) =>
                          //             const HistoryTabbar(initialView: 1)))
                          //     .whenComplete(() {
                          //   scheduleBloc.fetchSelectedSchedules(
                          //       DateTime.now().toString().substring(0, 10));
                          // });
                        },
                        icon: const Icon(CupertinoIcons.right_chevron))
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigator.of(context).push(
                  //   CardDialog(
                  //     builder: (context) {
                  //       return const AddHabit();
                  //     },
                  //   ),
                  // );
                },
                child: GridcardUtil(
                    content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            CupertinoIcons.add_circled,
                            size: 30,
                          ),
                        ]),
                  ],
                )),
              ),
            ],
          ),
        ),
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
              child: const Icon(CupertinoIcons.list_bullet),
              label: "Add Workout",
              labelBackgroundColor: Colors.redAccent[100],
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.of(context).push(CardDialog(builder: (context) {
                  return const AddHealth();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget
  Widget healthCard(BuildContext context,
      {String title = "",
      String data = "",
      Color color = const Color.fromARGB(255, 255, 238, 225),
      required String image}) {
    return Container(
      height: MediaQuery.of(context).size.width / 2.5,
      // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Image.asset(image, width: 60),
            Text(
              data,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
