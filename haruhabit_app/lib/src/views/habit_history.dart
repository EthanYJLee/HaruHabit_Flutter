import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
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
      body: FutureBuilder(
        future:
            handler.queryAllHabits(), // handler가 queryStudents 실행하면서 view 생성
        builder:
            (BuildContext context, AsyncSnapshot<List<HabitModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    HabitModel habitModel = HabitModel(
                      hId: snapshot.data?[index].hId,
                      category: "${snapshot.data?[index].category}",
                      habit: "${snapshot.data?[index].habit}",
                      spending: snapshot.data?[index].spending as int,
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Text('id : ${snapshot.data?[index].hId}'),
                        Text('category : ${snapshot.data?[index].category}'),
                        Text('habit : ${snapshot.data?[index].habit}'),
                        Text(
                            'date : ${snapshot.data?[index].startDate} ~ ${snapshot.data?[index].endDate}')
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
