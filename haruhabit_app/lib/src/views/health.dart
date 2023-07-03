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
import 'package:haruhabit_app/src/utils/header.dart';
import 'package:intl/date_time_patterns.dart';

import 'history_tabbar.dart';

class Health extends StatelessWidget {
  const Health({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
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
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
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
                        case HealthStatus.stepsReady:
                          // if (state.props.isEmpty) {
                          //   return const Center(
                          //     child: Text(
                          //       'no data',
                          //     ),
                          //   );
                          // }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  margin: const EdgeInsets.only(
                                      top: 30, right: 50, left: 50, bottom: 10),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.transparent,
                                              width: 5,
                                            ),
                                            color: Colors.redAccent[100],
                                            shape: BoxShape.circle),
                                      ),
                                      Container(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Steps",
                                                style: TextStyle(fontSize: 22),
                                              ),
                                              Text(
                                                state.model.steps.toString(),
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      )),
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
                const GridcardUtil(content: null),
              ],
            ),
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
}
