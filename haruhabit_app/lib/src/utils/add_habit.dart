import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:haruhabit_app/src/blocs/habit_bloc.dart';
import 'package:haruhabit_app/src/utils/database_handler.dart';
import 'package:haruhabit_app/src/utils/date_picker_item.dart';
import 'package:intl/intl.dart';

class AddHabit extends StatefulWidget {
  const AddHabit({super.key});

  @override
  State<AddHabit> createState() => _AddHabitState();
}

class _AddHabitState extends State<AddHabit> {
  late TextEditingController _categoryController = TextEditingController();
  late TextEditingController _habitController = TextEditingController();
  late TextEditingController _spendingController = TextEditingController();
  late String _category = "smoke free";
  late String _startDate = "";
  late String _habit = "";
  int _selectedRadio = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

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
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: (MediaQuery.of(context).viewInsets.bottom == 0)
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
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
                      height: MediaQuery.of(context).size.height / 2.1,
                      width: MediaQuery.of(context).size.width / 1.1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Create New Habit",
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _datePicker(),
                            const SizedBox(
                              height: 5,
                            ),
                            // _dropdownArea(),
                            Divider(thickness: 2, color: Colors.grey[300]),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _iconRadio(0,
                                      text: "Smoke \n Free",
                                      icon: Icons.smoke_free,
                                      category: 'smoke free'),
                                  _iconRadio(1,
                                      text: "No \n Drinks",
                                      icon: Icons.no_drinks,
                                      category: 'no drinks'),
                                  _iconRadio(2,
                                      text: "Drink \n Water",
                                      icon: Icons.water_drop_outlined,
                                      category: 'drink water'),
                                  _iconRadio(3,
                                      text: "Save \n Money",
                                      icon: Icons.attach_money,
                                      category: 'save money'),
                                  _iconRadio(4,
                                      text: "Workout \n /Exercise",
                                      icon: Icons.fitness_center,
                                      category: 'workout'),
                                  _iconRadio(5,
                                      text: "Create \n Your Own",
                                      icon: Icons.add_task,
                                      category: 'custom'),
                                ],
                              ),
                            ),
                            Divider(thickness: 2, color: Colors.grey[300]),

                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextField(
                                controller: _habitController,
                                decoration:
                                    const InputDecoration(hintText: "Details"),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextField(
                                controller: _spendingController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: "Daily Savings (Optional)"),
                              ),
                              // 금액 단위 TextField or Dropdown
                              //**
                              //
                              //
                              //
                              //
                              //
                              // */
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // 20자 넘어가면 Snack Bar
                                  if (_categoryController.text.length > 20) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Column(
                                        children: const [
                                          SizedBox(
                                              height: 16,
                                              child: Text(
                                                "Input category up to 20 letters",
                                                textAlign: TextAlign.center,
                                              )),
                                        ],
                                      ),
                                      dismissDirection: DismissDirection.up,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ));
                                  } else {
                                    // 빈 Text Field가 있으면
                                    if (_habitController.text == "") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Column(
                                          children: const [
                                            SizedBox(
                                                height: 16,
                                                child: Text(
                                                  "Fill in the category and detail fields",
                                                  textAlign: TextAlign.center,
                                                )),
                                          ],
                                        ),
                                        dismissDirection: DismissDirection.up,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ));
                                    } else {
                                      // // ----------------
                                      // _category = _categoryController.text;
                                      _habit = _habitController.text;
                                      _startDate =
                                          startDate.toString().substring(0, 10);
                                      print(startDate);
                                      print(_category);
                                      print(_startDate);
                                      print(_habit);
                                      habitBloc.addHabit(
                                          _category, _habit, 0, "", _startDate);

                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent[100],
                                ),
                                child: const Text(
                                  "Add",
                                ))
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
      ),
    );
  }

  Widget _datePicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DatePickerItem(
              children: <Widget>[
                const Text("Start Date"),
                CupertinoButton(
                  // disabledColor: Color.fromARGB(255, 164, 158, 255),
                  // color: Color.fromARGB(255, 164, 158, 255),
                  // Display a CupertinoDatePicker in date picker mode.
                  onPressed: () => _showDialog(
                    CupertinoDatePicker(
                      // backgroundColor: Color.fromARGB(255, 164, 158, 255),
                      initialDateTime: startDate,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      // This is called when the user changes the date.
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => startDate = newDate);
                        print(DateFormat('yyyy-MM-dd').format(startDate));
                      },
                    ),
                  ),
                  // In this example, the date is formatted manually. You can
                  // use the intl package to format the value based on the
                  // user's locale settings.
                  child: Text(
                    '${startDate.year}-${startDate.month.toString().padLeft(2, "0")}-${startDate.day.toString().padLeft(2, "0")}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.redAccent[100],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     DatePickerItem(
        //       children: <Widget>[
        //         Text("End Date"),
        //         CupertinoButton(
        //           // disabledColor: Color.fromARGB(255, 164, 158, 255),
        //           // color: Color.fromARGB(255, 164, 158, 255),
        //           // Display a CupertinoDatePicker in date picker mode.
        //           onPressed: () => _showDialog(
        //             CupertinoDatePicker(
        //               // backgroundColor: Color.fromARGB(255, 164, 158, 255),
        //               initialDateTime: endDate,
        //               mode: CupertinoDatePickerMode.date,
        //               use24hFormat: true,
        //               // This is called when the user changes the date.
        //               onDateTimeChanged: (DateTime newDate) {
        //                 setState(() => endDate = newDate);
        //                 print(DateFormat('yyyy-MM-dd').format(endDate));
        //               },
        //             ),
        //           ),
        //           // In this example, the date is formatted manually. You can
        //           // use the intl package to format the value based on the
        //           // user's locale settings.
        //           child: Text(
        //             '${endDate.year}-${endDate.month.toString().padLeft(2, "0")}-${endDate.day.toString().padLeft(2, "0")}',
        //             style: TextStyle(
        //               fontSize: 18.0,
        //               color: Colors.redAccent[100],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
      ],
    );
  }

  // /// Desc : 카테고리 선택하는 Dropdown Area
  // /// Date : 2023.05.24
  // /// Author : youngjin
  // Widget _dropdownArea() {
  //   // 요청사항 dropdown list
  //   final List<DropdownMenuEntry<String>> categoryEntries =
  //       <DropdownMenuEntry<String>>[];
  //   for (final _category in _categoryList) {
  //     categoryEntries
  //         .add(DropdownMenuEntry<String>(value: _category, label: _category));
  //   }

  //   return Container(
  //     height: MediaQuery.of(context).size.height / 14,
  //     width: MediaQuery.of(context).size.width / 1.1,
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: DropdownMenu(
  //             menuHeight: MediaQuery.of(context).size.height / 4.2,
  //             width: MediaQuery.of(context).size.width / 1.5,
  //             // initialSelection: _categoryList[0],
  //             initialSelection: "Select Category",
  //             controller: _categoryController,
  //             label: const Text(
  //               'Select Category',
  //               style: TextStyle(
  //                 color: Colors.black,
  //               ),
  //             ),
  //             inputDecorationTheme: const InputDecorationTheme(filled: true),
  //             dropdownMenuEntries: categoryEntries,
  //             onSelected: (value) {
  //               if (value == "+ Add New") {
  //                 _categoryController.text = "";
  //               }
  //               _category = _categoryController.text;
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _iconRadio(int index,
      {required String text,
      required IconData icon,
      required String category}) {
    return Padding(
      // padding: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedRadio == index ? Colors.red : null,
              size: 24,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _selectedRadio == index ? Colors.red : null)),
          ],
        ),
        onTap: () => setState(
          () {
            _selectedRadio = index;
            _category = category;
          },
        ),
      ),
    );
  }
}
