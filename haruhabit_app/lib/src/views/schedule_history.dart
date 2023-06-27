import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/calendar_bloc.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';

import '../models/schedule_model.dart';
import '../utils/calendar_utils.dart';

class ScheduleHistory extends StatelessWidget {
  const ScheduleHistory({super.key});

  @override
  Widget build(BuildContext context) {
    calendarBloc.getEventLists();
    return Scaffold(
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
                      // collapsedBackgroundColor: Colors.teal[100],
                      textColor: Colors.black,
                      iconColor: Colors.black,

                      /// Desc : Schedule이 있는 날짜를 중복 제거한 뒤 ExpansionTile의 대분류로 지정
                      /// Date : 2023.06.27
                      title: Text("${calendarBloc.kEvents.keys.toList()[index]}"
                          .substring(0, 10)),
                      subtitle: Text(
                          "${calendarBloc.kEvents.values.toList()[index].length} Tasks"),
                      children: <Widget>[
                        ListView.builder(
                            shrinkWrap: true,
                            // 중복 제거한 각 날짜별 일정 리스트의 길이
                            itemCount: calendarBloc.kEvents.values
                                .toList()[index]
                                .length,
                            itemBuilder: (BuildContext context, int i) {
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.1)),
                                child: ListTile(
                                  title: Text(
                                      '${calendarBloc.kEvents.values.toList()[index][i]}'),
                                  subtitle: Text(
                                      "${calendarBloc.kEvents[calendarBloc.kEvents.keys.toList()[index]][i].place}"),
                                  trailing: Text(
                                      "${calendarBloc.kEvents[calendarBloc.kEvents.keys.toList()[index]][i].hour}" +
                                          " : " +
                                          "${calendarBloc.kEvents[calendarBloc.kEvents.keys.toList()[index]][i].minute}"),
                                ),
                              );
                            }),
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
