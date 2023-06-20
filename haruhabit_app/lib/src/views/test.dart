import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:haruhabit_app/src/views/history.dart';
import 'package:intl/intl.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    scheduleBloc.fetchAllSchedules();
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => const History()));
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const Calendar()))
                      .whenComplete(() => scheduleBloc.fetchAllSchedules());
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: Center(
          child: Column(
            children: [
              _calendarTimeline(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.teal[200]),
                      ),
                      child: Text(
                        // '${DateFormat.yMMMMd('ko').format(DateTime.now())}',
                        '${DateFormat.yMMMd('en').format(DateTime.now())}',
                        style: const TextStyle(
                            color: Color(0xFF333A47),
                            fontWeight: FontWeight.bold),
                      ),
                      // onPressed: () => setState(() => _resetSelectedDate()),
                      onPressed: () {
                        //-
                      },
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
              Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                  stream: scheduleBloc.allSchedule,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data!.length);
                      return GridView.builder(
                          itemCount: snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5),
                          itemBuilder: (BuildContext context, int index) {
                            return GridTile(
                                child: GestureDetector(
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
                                    // Text('id : ${snapshot.data?[index].sId}'),
                                    // Text('date : ${snapshot.data?[index].date}'),
                                    Text(
                                        'schedule : ${snapshot.data?[index].schedule}'),
                                    // Text('place : ${snapshot.data?[index].place}'),
                                    // Text('hour : ${snapshot.data?[index].hour}'),
                                    // Text('minute : ${snapshot.data?[index].minute}'),
                                  ],
                                ),
                              ),
                            ));
                          });
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _calendarTimeline() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          decoration: const BoxDecoration(),
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
            // locale: 'ko',
            locale: 'en',
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       TextButton(
        //         style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all(Colors.teal[200]),
        //         ),
        //         child: Text(
        //           // '${DateFormat.yMMMMd('ko').format(DateTime.now())}',
        //           '${DateFormat.yMMMd('en').format(DateTime.now())}',
        //           style: const TextStyle(
        //               color: Color(0xFF333A47), fontWeight: FontWeight.bold),
        //         ),
        //         // onPressed: () => setState(() => _resetSelectedDate()),
        //         onPressed: () {
        //           //-
        //         },
        //       ),
        //       const Text(
        //         "You've got ${"0"} tasks today",
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
