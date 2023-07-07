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
                                width: MediaQuery.of(context).size.width / 1.3,
                                child: const Text(
                                  "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your data",
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
                                width: MediaQuery.of(context).size.width / 1.3,
                                child: const Text(
                                  "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your data",
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
                        // if (state.props.isEmpty) {
                        //   return const Center(
                        //     child: Text(
                        //       'no data',
                        //     ),
                        //   );
                        // }
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 4.8,
                          // margin: const EdgeInsets.only(
                          //     right: 50, left: 50, bottom: 10),
                          margin: const EdgeInsets.only(bottom: 30),
                          padding: const EdgeInsets.all(10),
                          child: Stack(
                            // alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.transparent,
                                      // width: 5,
                                    ),
                                    // color: Colors.redAccent[100],
                                    color: const Color.fromARGB(
                                        255, 255, 238, 225),
                                    shape: BoxShape.circle),
                              ),
                              Container(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Steps",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22)),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.asset(
                                          "assets/images/footprint.png",
                                          height: 50,
                                        ),
                                      ),
                                      Text(
                                        state.model.steps.toString(),
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              )),
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
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                child: Row(
                  children: [
                    Expanded(
                        child: healthCard(context,
                            title: 'Heart Rate',
                            data: "0",
                            image: "assets/images/heart-attack.png")),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: healthCard(context,
                            title: 'Workout',
                            data: "0",
                            image: "assets/images/fitness.png")),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                // padding: EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width / 1.1,
                child: Row(
                  children: [
                    Expanded(
                        child: healthCard(context,
                            title: 'Blood Pressure',
                            data: "0",
                            image: "assets/images/blood-pressure.png")),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: healthCard(context,
                            title: 'Energy Burned',
                            data: "0",
                            image: "assets/images/calories.png")),
                  ],
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     //-
              //     print(HealthBloc.dataTypes);
              //   },
              //   child: GridcardUtil(
              //       content: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: const [
              //             Icon(
              //               CupertinoIcons.add_circled,
              //               size: 30,
              //             ),
              //           ]),
              //     ],
              //   )),
              // ),
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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
