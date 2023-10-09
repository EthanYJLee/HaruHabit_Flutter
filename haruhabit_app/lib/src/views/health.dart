import 'package:easy_localization/easy_localization.dart';
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
import 'package:haruhabit_app/src/views/sports_categories.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:path/path.dart';

import 'history_tabbar.dart';

class Health extends StatefulWidget {
  const Health({super.key});

  @override
  State<Health> createState() => _HealthState();
}

class _HealthState extends State<Health> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Divider(thickness: 2, color: Colors.white),
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Health',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
                        case HealthStatus.initial:
                          return const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
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
                                      MediaQuery.of(context).size.width / 1.5,
                                  padding: const EdgeInsets.only(
                                      top: 50, bottom: 50),
                                  child: const Text(
                                    "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your health data",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
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
                                      MediaQuery.of(context).size.width / 1.5,
                                  padding: const EdgeInsets.only(
                                      top: 50, bottom: 50),
                                  child: const Text(
                                    "Go to Settings > Health > Data Access & Devices > Haru Habit > turn access on to get your health data",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
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
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: healthCard(context,
                                              title: 'stepCount'.tr(),
                                              data:
                                                  "${state.model.steps.toString().split('.')[0]} steps",
                                              image:
                                                  "assets/images/footprint.png")),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: healthCard(context,
                                              title: 'heartRate'.tr(),
                                              data:
                                                  "${state.model.heartRate.toString().split('.')[0]} bpm",
                                              image:
                                                  "assets/images/heart-attack.png")),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: healthCard(context,
                                              title: 'bloodPressure'.tr(),
                                              data: state.model.bp.toString(),
                                              image:
                                                  "assets/images/blood-pressure.png")),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: healthCard(context,
                                              title: 'energyBurned'.tr(),
                                              data:
                                                  "${state.model.energyBurned} kcal",
                                              image:
                                                  "assets/images/calories.png")),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );

                        case HealthStatus.failure:
                          return const Center(
                            child: Text(
                              'Failed to fetch Health Data',
                            ),
                          );
                      }
                    },
                  ),
                ),
                const Divider(thickness: 2, color: Colors.white),
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            const Text(
                              'Workout',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(CupertinoIcons.right_chevron))
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  // Navigator.of(context)
                                  //     .push(MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             Calendar(day: DateTime.now())))
                                  //     .whenComplete(() {
                                  //   scheduleBloc.fetchSelectedSchedules(
                                  //       DateTime.now()
                                  //           .toString()
                                  //           .substring(0, 10));
                                  // });
                                  // Navigator.of(context).push(CardDialog(
                                  //     builder: (context) => const AddHealth()));
                                  return showWorkoutBottomSheet(context);
                                },
                                icon: const Icon(
                                  CupertinoIcons.add,
                                  color: Colors.white,
                                )),
                            IconButton(
                                onPressed: () {
                                  // Navigator.of(context)
                                  //     .push(MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             const HistoryTabbar(
                                  //                 initialView: 0)))
                                  //     .whenComplete(() {
                                  //   scheduleBloc.fetchSelectedSchedules(
                                  //       DateTime.now()
                                  //           .toString()
                                  //           .substring(0, 10));
                                  // });
                                },
                                icon: const Icon(
                                  CupertinoIcons.right_chevron,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context)
                //         .push(CardDialog(builder: (context) => AddHealth()));
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
        ),
        // floatingActionButton: SpeedDial(
        //   backgroundColor: Colors.redAccent[100],
        //   overlayColor: Colors.black,
        //   icon: Icons.add,
        //   activeIcon: Icons.close,
        //   direction: SpeedDialDirection.up,
        //   childPadding: const EdgeInsets.all(5),
        //   spaceBetweenChildren: 4,
        //   spacing: 3,
        //   useRotationAnimation: true,
        //   animationCurve: Curves.easeInOutQuart,
        //   children: [
        //     SpeedDialChild(
        //       child: const Icon(CupertinoIcons.list_bullet),
        //       label: "Add Workout",
        //       labelBackgroundColor: Colors.redAccent[100],
        //       labelStyle: const TextStyle(color: Colors.white),
        //       backgroundColor: Colors.redAccent[100],
        //       foregroundColor: Colors.white,
        //       onTap: () {
        //         Navigator.of(context).push(CardDialog(builder: (context) {
        //           return const AddHealth();
        //         }));
        //       },
        //     ),
        //   ],
        // ),
      ),
    );
  }

  // Widget
  Widget healthCard(BuildContext context,
      {String title = "",
      String data = "",
      // Color color = const Color.fromARGB(255, 255, 238, 225),
      Color color = Colors.white,
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

  /// 운동 기록을 위해 카테고리를 선택하는 modal bottom sheet
  void showWorkoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        snap: true,
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.69,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              color: Colors.white,
              // child: Streak(
              //   hId: hId,
              //   startDate: startDate,
              // ),
              child: SportsCategories(),
            ),
          );
        },
      ),
    );
  }
}
