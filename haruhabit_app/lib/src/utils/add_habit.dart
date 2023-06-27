import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/utils/date_picker_item.dart';
import 'package:haruhabit_app/src/view_models/habit_viewmodel.dart';
import 'package:intl/intl.dart';

class AddHabit extends StatefulWidget {
  const AddHabit({super.key});

  @override
  State<AddHabit> createState() => _AddHabitState();
}

class _AddHabitState extends State<AddHabit> {
  HabitViewModel _habitViewModel = HabitViewModel();
  late TextEditingController _categoryController = TextEditingController();
  late TextEditingController _habitController = TextEditingController();
  late String _category = "";
  late String _startDate = "";
  late String _habit = "";
  late List<String> _categoryList = ["직접 입력", "금연", "금주", "공부"];
  DateTime date = DateTime.now();

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
                              "추가",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _dropdownArea(),
                          _datePicker(),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: TextField(
                              controller: _habitController,
                              decoration: const InputDecoration(hintText: "내용"),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                // 20자 넘어가면 Snack Bar
                                if (_categoryController.text.trim().length >
                                    20) {
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
                                  if (_categoryController.text == "" ||
                                      _habitController.text == "") {
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ));
                                  } else {
                                    // ----------------
                                    _category = _categoryController.text;
                                    _startDate =
                                        DateFormat('yyyy-MM-dd').format(date);
                                    _habit = _habitController.text;
                                    print(_category);
                                    print(_startDate);
                                    print(_habit);
                                    _habitViewModel.addHabit(
                                        _category, _habit, _startDate);

                                    Navigator.pop(context);
                                  }
                                }
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

  Widget _datePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePickerItem(
          children: <Widget>[
            const Text("시작일"),
            CupertinoButton(
              // disabledColor: Color.fromARGB(255, 164, 158, 255),
              // color: Color.fromARGB(255, 164, 158, 255),
              // Display a CupertinoDatePicker in date picker mode.
              onPressed: () => _showDialog(
                CupertinoDatePicker(
                  // backgroundColor: Color.fromARGB(255, 164, 158, 255),
                  initialDateTime: date,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => date = newDate);
                    print(DateFormat('yyyy-MM-dd').format(date));
                  },
                ),
              ),
              // In this example, the date is formatted manually. You can
              // use the intl package to format the value based on the
              // user's locale settings.
              child: Text(
                '${date.year}-${date.month}-${date.day}',
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

  /// Desc : 카테고리 선택하는 Dropdown Area
  /// Date : 2023.05.24
  /// Author : youngjin
  Widget _dropdownArea() {
    // 요청사항 dropdown list
    final List<DropdownMenuEntry<String>> categoryEntries =
        <DropdownMenuEntry<String>>[];
    for (final _category in _categoryList) {
      categoryEntries
          .add(DropdownMenuEntry<String>(value: _category, label: _category));
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
              controller: _categoryController,
              label: const Text(
                '카테고리',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(filled: true),
              dropdownMenuEntries: categoryEntries,
              onSelected: (value) {
                if (value == "직접 입력") {
                  _categoryController.text = "";
                }
                _category = _categoryController.text;
              },
            ),
          ),
        ],
      ),
    );
  }
}
