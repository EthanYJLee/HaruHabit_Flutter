import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:health/health.dart';

class AddHealth extends StatefulWidget {
  const AddHealth({super.key});

  @override
  State<AddHealth> createState() => _AddHealthState();
}

class _AddHealthState extends State<AddHealth> {
  late List<String> _workoutLists =
      HealthWorkoutActivityType.values.map((e) => e.name).toList();

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
                          const Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: TextField(
                              decoration: InputDecoration(hintText: "내용"),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                print(_workoutLists);
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
}
