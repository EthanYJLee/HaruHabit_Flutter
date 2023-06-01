import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/utils/calendar_utils.dart';
import 'package:haruhabit_app/utils/date_picker_item.dart';
import 'package:haruhabit_app/view_models/schedule_viewmodel.dart';
import 'package:haruhabit_app/views/calendar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  State<CreateSchedule> createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  ScheduleViewModel _scheduleViewModel = ScheduleViewModel();
  late TextEditingController _scheduleController;
  late TextEditingController _placeController;
  late String _schedule;
  late String _place;
  late int hour = 12;
  late int minute = 30;

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
                  height: MediaQuery.of(context).size.height / 1.8,
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // 선택한 날짜 보여주기
                      Text(
                        "${widget.selectedDate.toString().substring(
                              0,
                              10,
                            )}",
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
                          decoration: const InputDecoration(hintText: "일정"),
                        ),
                      ),

                      // 장소 입력하는 Text Field
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: _placeController,
                          decoration: const InputDecoration(hintText: "장소"),
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
                                _scheduleViewModel.addSchedule(
                                  widget.selectedDate.toString().substring(
                                        0,
                                        10,
                                      ),
                                  _schedule,
                                  _place,
                                  hour.toString(),
                                  minute.toString(),
                                );

                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: const Text(
                            "추가",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
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
            const Text("시간"),
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
                  use24hFormat: true,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      hour = newTime.hour;
                      minute = newTime.minute;
                    });
                  },
                ),
              ),
              // In this example, the date is formatted manually. You can
              // use the intl package to format the value based on the
              // user's locale settings.
              child: Text(
                "${hour}시 ${minute}분",
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
