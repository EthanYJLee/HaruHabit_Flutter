import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Localizations.override(
                context: context,
                locale: const Locale('ko'),
                child: Container(
                  height: 300,
                  child: CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000, 1, 1),
                    lastDate: DateTime(2025, 12, 31),
                    currentDate: _focusedDay,
                    onDateChanged: (value) {
                      _selectedDay = value;
                      print(_selectedDay);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
