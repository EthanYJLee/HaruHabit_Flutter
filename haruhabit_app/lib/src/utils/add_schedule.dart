import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/schedule_bloc.dart';
import 'package:haruhabit_app/src/utils/calendar_utils.dart';
import 'package:haruhabit_app/src/utils/date_picker_item.dart';
import 'package:haruhabit_app/src/views/calendar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  late TextEditingController _scheduleController;
  late TextEditingController _placeController;
  late String _schedule;
  late String _place;
  late int hour = 12;
  late int minute = 00;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scheduleController = TextEditingController();
    _placeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'addSchedule',
              createRectTween: (begin, end) {
                return RectTween(begin: begin, end: end);
              },
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // 선택한 날짜 보여주기
                      Text(
                        widget.selectedDate.toString().substring(0, 10),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      // 시간 선택하는 Date Picker
                      _timePicker(),
                      // 일정 입력하는 Text Field
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: _scheduleController,
                          decoration:
                              const InputDecoration(hintText: "Schedule"),
                        ),
                      ),

                      // 장소 입력하는 Text Field
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: _placeController,
                          decoration:
                              const InputDecoration(hintText: "Location"),
                        ),
                      ),

                      // schedules DB에 데이터 입력
                      TextButton(
                          onPressed: () {
                            //-
                            // 20자 넘어가면 Snack Bar
                            if (_scheduleController.text.trim().length > 20) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Column(
                                  children: const [
                                    SizedBox(
                                        height: 16,
                                        child: Text(
                                          "20자 이내로 입력해주십시오",
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                                dismissDirection: DismissDirection.up,
                                duration: const Duration(milliseconds: 500),
                              ));
                            } else {
                              // 빈 Text Field가 있으면
                              if (_scheduleController.text == "" ||
                                  _placeController.text == "") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Column(
                                    children: const [
                                      SizedBox(
                                          height: 16,
                                          child: Text(
                                            "내용을 입력해주세요",
                                            textAlign: TextAlign.center,
                                          )),
                                    ],
                                  ),
                                  dismissDirection: DismissDirection.up,
                                  duration: const Duration(milliseconds: 500),
                                ));
                              } else {
                                // ----------------
                                _schedule = _scheduleController.text;
                                _place = _placeController.text;
                                scheduleBloc.addSchedule(
                                  widget.selectedDate.toString().substring(
                                        0,
                                        10,
                                      ),
                                  _schedule,
                                  _place,
                                  hour,
                                  minute,
                                  0,
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------Widgets---------------------

  Widget _timePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePickerItem(
          children: <Widget>[
            const Text("Time"),
            CupertinoButton(
              // disabledColor: Color.fromARGB(255, 164, 158, 255),
              // color: Color.fromARGB(255, 164, 158, 255),
              // Display a CupertinoDatePicker in date picker mode.
              onPressed: () => _showDialog(
                CupertinoDatePicker(
                  // backgroundColor: Color.fromARGB(255, 164, 158, 255),
                  initialDateTime: DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day, hour, minute),
                  mode: CupertinoDatePickerMode.time,
                  // 분 간격
                  minuteInterval: 5,
                  use24hFormat: false,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      hour = newTime.hour;
                      minute = newTime.minute;
                    });
                  },
                ),
              ),
              // The date is formatted manually here. You can
              // use the intl package to format the value based on the
              // user's locale settings.
              // 기기 설정에 따라 locale 자동 적용
              child: Text(
                "${hour}".padLeft(2, "0") + " : " + "${minute}".padLeft(2, "0"),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.redAccent[100],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // ---------------------Functions---------------------

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}
