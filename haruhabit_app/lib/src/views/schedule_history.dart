import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/schedule_model.dart';
import '../utils/calendar_utils.dart';

class ScheduleHistory extends StatelessWidget {
  const ScheduleHistory({super.key});

  @override
  Widget build(BuildContext context) {
    calendarBloc.getEventLists();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: calendarBloc.eventList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(border: Border.all(width: 0.1)),
                    child: ExpansionTile(
                      collapsedBackgroundColor: Colors.white,
                      backgroundColor: Colors.white,
                      // collapsedBackgroundColor: Colors.teal[100],
                      textColor: Colors.black,
                      iconColor: Colors.black,
                      // collapsedBackgroundColor:
                      //     const Color.fromARGB(255, 255, 238, 225),

                      /// Desc : Schedule이 있는 날짜를 중복 제거한 뒤 ExpansionTile의 대분류로 지정
                      /// Date : 2023.06.27
                      title: Text("${calendarBloc.kEvents.keys.toList()[index]}"
                          .substring(0, 10)),
                      subtitle: Text(
                          "${calendarBloc.kEvents.values.toList()[index].length} Tasks"),
                      children: <Widget>[
                        ListView.builder(
                          physics: const BouncingScrollPhysics(
                              decelerationRate: ScrollDecelerationRate.normal),
                          shrinkWrap: true,
                          // 중복 제거한 각 날짜별 일정 리스트의 길이
                          itemCount: calendarBloc.kEvents.values
                              .toList()[index]
                              .length,
                          itemBuilder: (context, i) => Slidable(
                            key: Key(calendarBloc.kEvents.values
                                .toList()[index]
                                .toString()),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                // 스케쥴 수정 버튼
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
                                // 스케쥴 삭제 버튼
                                SlidableAction(
                                  flex: 2,
                                  onPressed: (context) {
                                    handler.deleteSchedule(calendarBloc
                                        .kEvents[calendarBloc.kEvents.keys
                                            .toList()[index]][i]
                                        .sId);
                                    calendarBloc.getEventLists();
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
                                  '${calendarBloc.kEvents.values.toList()[index][i]}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                subtitle: Text(
                                  '${calendarBloc.kEvents[calendarBloc.kEvents.keys.toList()[index]][i].place}',
                                  style: const TextStyle(
                                      color: Color.fromARGB(198, 33, 33, 33)),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
