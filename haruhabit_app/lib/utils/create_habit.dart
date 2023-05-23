import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class CreateHabit extends StatefulWidget {
  const CreateHabit({super.key});

  @override
  State<CreateHabit> createState() => _CreateHabitState();
}

class _CreateHabitState extends State<CreateHabit> {
  late TextEditingController requestController = TextEditingController();
  late TextEditingController _titleController = TextEditingController();
  late List<String> _categoryList = ["금연", "금주", "공부", "직접 입력"];
  late String request = '';
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
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.all(30),
          child: Hero(
            tag: '',
            createRectTween: (begin, end) {
              return RectTween(begin: begin, end: end);
            },
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
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
                      // TextField(
                      //   controller: requestController,
                      //   decoration: InputDecoration(helperText: '요청사항을 입력해주세요'),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DatePickerItem(
                            children: <Widget>[
                              const Text("시작일"),
                              CupertinoButton(
                                // Display a CupertinoDatePicker in date picker mode.
                                onPressed: () => _showDialog(
                                  CupertinoDatePicker(
                                    initialDateTime: date,
                                    mode: CupertinoDatePickerMode.date,
                                    use24hFormat: true,
                                    // This is called when the user changes the date.
                                    onDateTimeChanged: (DateTime newDate) {
                                      setState(() => date = newDate);
                                    },
                                  ),
                                ),
                                // In this example, the date is formatted manually. You can
                                // use the intl package to format the value based on the
                                // user's locale settings.
                                child: Text(
                                  '${date.year}-${date.month}-${date.day}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: _titleController,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _dropdownArea(),

                      ElevatedButton(
                          onPressed: () {
                            if (requestController.text.trim().length > 20) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Column(
                                  children: const [
                                    SizedBox(
                                        height: 15,
                                        child: Text(
                                          '20자 이내로 입력해주십시오',
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                                dismissDirection: DismissDirection.up,
                                duration: const Duration(milliseconds: 500),
                              ));
                            } else {
                              if (requestController.text == '선택 안 함' ||
                                  requestController.text == '') {
                                Navigator.of(context).pop();
                              } else {
                                // ----------------
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text('입력'))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// Desc : 카테고리 선택하는 dropdownarea
  /// Date : 2023.05.24
  /// Author : youngjin
  Widget _dropdownArea() {
    // 요청사항 dropdown list
    final List<DropdownMenuEntry<String>> requestEntries =
        <DropdownMenuEntry<String>>[];
    for (final _category in _categoryList) {
      requestEntries
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
              initialSelection: _categoryList[0],
              controller: requestController,
              label: const Text(
                '카테고리',
                style: TextStyle(color: Colors.black),
              ),
              dropdownMenuEntries: requestEntries,
              onSelected: (value) {
                if (value == '직접 입력') {
                  requestController.text = '';
                }
                request = requestController.text;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
          bottom: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
