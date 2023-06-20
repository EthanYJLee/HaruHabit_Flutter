import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';

class ScheduleHistory extends StatefulWidget {
  const ScheduleHistory({super.key});

  @override
  State<ScheduleHistory> createState() => _ScheduleHistoryState();
}

class _ScheduleHistoryState extends State<ScheduleHistory> {
  late DatabaseHandler handler;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handler = DatabaseHandler();
    // whenComplete는 hold하는 용도로 쓰임.

    handler.initializeDB('schedules').whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: FutureBuilder(
        future:
            handler.querySchedules(), // handler가 queryStudents 실행하면서 view 생성
        builder: (BuildContext context,
            AsyncSnapshot<List<ScheduleModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    ScheduleModel scheduleModel = ScheduleModel(
                      sId: snapshot.data?[index].sId,
                      date: "${snapshot.data?[index].date}",
                      schedule: "${snapshot.data?[index].schedule}",
                      place: "${snapshot.data?[index].place}",
                      hour: "${snapshot.data?[index].hour}",
                      minute: "${snapshot.data?[index].minute}",
                    );
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: ((context) => UpdateStudent()),
                    //   ),
                    // );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Text('id : ${snapshot.data?[index].sId}'),
                        Text('date : ${snapshot.data?[index].date}'),
                        Text('schedule : ${snapshot.data?[index].schedule}'),
                        Text('place : ${snapshot.data?[index].place}'),
                        Text('hour : ${snapshot.data?[index].hour}'),
                        Text('minute : ${snapshot.data?[index].minute}'),
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
    ));
  }
}
