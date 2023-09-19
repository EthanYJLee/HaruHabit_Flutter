import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:haruhabit_app/src/models/habit_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';

class HabitHistory extends StatefulWidget {
  const HabitHistory({super.key});

  @override
  State<HabitHistory> createState() => _HabitHistoryState();
}

class _HabitHistoryState extends State<HabitHistory> {
  late DatabaseHandler handler;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handler = DatabaseHandler();
    // whenComplete는 hold하는 용도로 쓰임.
    handler.initializeDB('habits').whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            ExpansionTile(
              collapsedBackgroundColor: Colors.white,
              backgroundColor: Colors.white,
              title: const Text('Done'),
              children: [
                FutureBuilder(
                  future: handler
                      .queryHabitsDone(), // handler가 queryAllHabits 실행하면서 view 생성
                  builder: (BuildContext context,
                      AsyncSnapshot<List<HabitModel>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              HabitModel habitModel = HabitModel(
                                hId: snapshot.data?[index].hId,
                                category: "${snapshot.data?[index].category}",
                                habit: "${snapshot.data?[index].habit}",
                                spending: snapshot.data?[index].spending as int,
                                currency: "${snapshot.data?[index].currency}",
                                startDate: "${snapshot.data?[index].startDate}",
                                endDate: "${snapshot.data?[index].endDate}",
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: ((context) => UpdateStudent()),
                              //   ),
                              // );
                            },
                            child: Card(
                              color: (DateTime.now()
                                      .difference(DateTime.parse(
                                          snapshot.data![index].startDate))
                                      .isNegative)
                                  ? Color.fromARGB(255, 203, 203, 203)
                                  : Color.fromARGB(255, 255, 238, 225),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                              child: Column(
                                children: [
                                  // Text('id : ${snapshot.data?[index].hId}'),
                                  // Text(
                                  //     'Category : ${snapshot.data?[index].category}'),
                                  Text(
                                    'Habit : ${snapshot.data?[index].habit}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                      'Start Date : ${snapshot.data?[index].startDate}'),
                                  Text(
                                      'End Date : ${snapshot.data?[index].endDate}'),
                                  // (DateTime.now()
                                  //         .difference(DateTime.parse(
                                  //             snapshot.data![index].startDate))
                                  //         .isNegative)
                                  //     ? Text('not yet')
                                  //     : Text('on progress')
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
            ExpansionTile(
              collapsedBackgroundColor: Colors.white,
              backgroundColor: Colors.white,
              title: const Text('On progress'),
              children: [
                FutureBuilder(
                  future: handler
                      .queryAllHabits(), // handler가 queryAllHabits 실행하면서 view 생성
                  builder: (BuildContext context,
                      AsyncSnapshot<List<HabitModel>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.normal),
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, i) => Slidable(
                          key: Key(snapshot.data![i].hId.toString()),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              // 습관 수정 버튼
                              SlidableAction(
                                onPressed: (context) {
                                  //-
                                },
                                flex: 2,
                                foregroundColor: Colors.black,
                                backgroundColor:
                                    Color.fromARGB(255, 53, 117, 255),
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              // // 습관 끝내기 버튼
                              // SlidableAction(
                              //   onPressed: (context) {
                              //     //-
                              //   },
                              //   flex: 2,
                              //   foregroundColor: Colors.black,
                              //   backgroundColor:
                              //       Color.fromARGB(255, 255, 164, 53),
                              //   icon: Icons.edit,
                              //   label: 'Finish',
                              // ),
                              // 습관 삭제 버튼
                              SlidableAction(
                                flex: 2,
                                onPressed: (context) {
                                  // handler.deleteSchedule(calendarBloc
                                  //     .kEvents[calendarBloc.kEvents.keys
                                  //         .toList()[index]][i]
                                  //     .sId);
                                  // calendarBloc.getEventLists();
                                  handler.deleteHabit(
                                      snapshot.data![i].hId.toString());
                                  setState(() {});
                                },
                                foregroundColor: Colors.black,
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 48, 48),
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            color: const Color.fromARGB(255, 255, 238, 225),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: ListTile(
                              title: Text(
                                '${snapshot.data![i].habit}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                'Start Date : ${snapshot.data![i].startDate}',
                                style: const TextStyle(
                                    color: Color.fromARGB(198, 33, 33, 33)),
                              ),
                              // trailing: const Icon(
                              //   Icons.arrow_forward_ios_rounded,
                              //   color: Colors.black,
                              // ),
                              trailing: ElevatedButton(
                                  onPressed: () {
                                    ///------------------
                                    ///
                                    ///
                                    ///
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent[100]),
                                  child: const Text('End habit')),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
