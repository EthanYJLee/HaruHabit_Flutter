import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:health/health.dart';

import 'date_picker_item.dart';

class AddHealth extends StatefulWidget {
  const AddHealth({super.key});

  @override
  State<AddHealth> createState() => _AddHealthState();
}

class _AddHealthState extends State<AddHealth> {
  late List<String> _workoutLists =
      HealthWorkoutActivityType.values.map((e) => e.name).toList();
  late int startHour = 12;
  late int startMinute = 30;
  late int endHour = 12;
  late int endMinute = 30;

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
            Padding(
              padding: const EdgeInsets.all(30),
              child: Hero(
                tag: "addHabit",
                createRectTween: (begin, end) {
                  return RectTween(begin: begin, end: end);
                },
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              "Add Workout",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          _dropdownArea(),
                          const SizedBox(
                            height: 20,
                          ),
                          // const Padding(
                          //   padding: EdgeInsets.only(left: 20, right: 20),
                          //   child: TextField(
                          //     decoration: InputDecoration(hintText: "내용"),
                          //   ),
                          // ),
                          _timeRangePicker(),

                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                // print(_workoutLists);
                              },
                              child: const Text("추가"))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownArea() {
    // 요청사항 dropdown list
    final List<DropdownMenuEntry<String>> workoutEntries =
        <DropdownMenuEntry<String>>[];
    for (final _workout in _workoutLists) {
      workoutEntries
          .add(DropdownMenuEntry<String>(value: _workout, label: _workout));
    }

    return Container(
      height: MediaQuery.of(context).size.height / 14,
      width: MediaQuery.of(context).size.width / 1.1,
      child: Column(
        children: [
          Expanded(
            child: DropdownMenu(
              menuHeight: 320,
              width: MediaQuery.of(context).size.width / 1.5,
              // initialSelection: _categoryList[0],
              initialSelection: "",
              // controller: _categoryController,
              label: const Text(
                'Category',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(filled: true),
              dropdownMenuEntries: workoutEntries,
              onSelected: (value) {
                //-
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePickerItem(
          children: <Widget>[
            CupertinoButton(
              // disabledColor: Color.fromARGB(255, 164, 158, 255),
              // color: Color.fromARGB(255, 164, 158, 255),
              // Display a CupertinoDatePicker in date picker mode.
              onPressed: () => _showDialog(
                CupertinoDatePicker(
                  // backgroundColor: Color.fromARGB(255, 164, 158, 255),
                  initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      startHour,
                      startMinute),
                  mode: CupertinoDatePickerMode.time,
                  // 분 간격
                  minuteInterval: 5,
                  use24hFormat: false,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      startHour = newTime.hour;
                      startMinute = newTime.minute;
                    });
                  },
                ),
              ),
              // The date is formatted manually here. You can
              // use the intl package to format the value based on the
              // user's locale settings.
              // 기기 설정에 따라 locale 자동 적용
              child: Text(
                "${startHour}".padLeft(2, "0") +
                    " : " +
                    "${startMinute}".padLeft(2, "0"),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.redAccent[100],
                ),
              ),
            ),
          ],
        ),
        const Text(" ~ "),
        DatePickerItem(
          children: <Widget>[
            CupertinoButton(
              // disabledColor: Color.fromARGB(255, 164, 158, 255),
              // color: Color.fromARGB(255, 164, 158, 255),
              // Display a CupertinoDatePicker in date picker mode.
              onPressed: () => _showDialog(
                CupertinoDatePicker(
                  // backgroundColor: Color.fromARGB(255, 164, 158, 255),
                  initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      endHour,
                      endMinute),
                  mode: CupertinoDatePickerMode.time,
                  // 분 간격
                  minuteInterval: 5,
                  use24hFormat: false,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      endHour = newTime.hour;
                      endMinute = newTime.minute;
                    });
                  },
                ),
              ),
              // The date is formatted manually here. You can
              // use the intl package to format the value based on the
              // user's locale settings.
              // 기기 설정에 따라 locale 자동 적용
              child: Text(
                "${endHour}".padLeft(2, "0") +
                    " : " +
                    "${endMinute}".padLeft(2, "0"),
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

  // Functions
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
