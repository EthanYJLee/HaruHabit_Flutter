import 'dart:async';

import 'package:haruhabit_app/src/models/habit_model.dart';
import 'package:haruhabit_app/src/models/schedule_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

import 'calendar_utils.dart';

class DatabaseHandler {
  // Initialize SQLite Database
  Future<Database> initializeDB(String db) async {
    String path = await getDatabasesPath();
    switch (db) {
      case 'habits':
        return openDatabase(
          join(
            path,
            'habits.db',
          ),
          onCreate: (database, version) async {
            await database.execute(
                'CREATE TABLE IF NOT EXISTS habits (hId INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, habit TEXT, startDate TEXT, endDate TEXT)');
          },
          version: 1,
        );
      default:
        return openDatabase(
          join(
            path,
            'schedules.db',
          ),
          onCreate: (database, version) async {
            await database.execute(
                'CREATE TABLE IF NOT EXISTS schedules (sId INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, schedule TEXT, place TEXT, hour TEXT, minute TEXT, isDone INTEGER)');
          },
          version: 1,
        );
    }
  }
  // ----------Schedules----------

  // read all schedules
  Future<List<ScheduleModel>> queryAllSchedules() async {
    final Database db = await initializeDB('schedules');
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery('SELECT * FROM schedules');
    return queryResult.map((e) => ScheduleModel.fromMap(e)).toList();
  }

  // read selected day's schedules
  Future<List<ScheduleModel>> querySelectedSchedules(
      String selectedDate) async {
    final Database db = await initializeDB('schedules');
    final List<Map<String, Object?>> queryResult =
        // await db.rawQuery('SELECT * FROM schedules');
        await db.query('schedules',
            columns: [
              'sId',
              'date',
              'schedule',
              'place',
              'hour',
              'minute',
              'isDone'
            ],
            where: 'date = ?',
            whereArgs: [selectedDate]);
    // print(queryResult.map((e) => ScheduleModel.fromMap(e)).toList());
    return queryResult.map((e) => ScheduleModel.fromMap(e)).toList();
  }

  // Future<int> scheduleIsDone(ScheduleModel scheduleModel) async {
  //   final Database db = await openDatabase('schedules.db');
  //   int count = await db.rawUpdate(
  //       'UPDATE schedules SET name = ?, dept = ?, phone = ? WHERE code = ?',
  //       [student.name, student.dept, student.phone, student.code]);
  //   return count;
  // }

  // ----------Habits----------

  // read all habits
  Future<List<HabitModel>> queryAllHabits() async {
    final Database db = await initializeDB('habits');
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery('SELECT * FROM habits');
    return queryResult.map((e) => HabitModel.fromMap(e)).toList();
  }

  // insert new habit into DB
  Future insertHabit(HabitModel habitModel) async {
    int result = 0;
    final db = await initializeDB('habits');
    result = await db.rawInsert(
      'INSERT INTO habits (hId, category, habit, startDate, endDate) VALUES (?,?,?,?,?)',
      [
        habitModel.hId,
        habitModel.category,
        habitModel.habit,
        habitModel.startDate,
        habitModel.endDate
      ],
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // insert new schedule into DB
  Future insertSchedule(ScheduleModel scheduleModel) async {
    int result = 0;
    final db = await initializeDB('schedules');
    result = await db.rawInsert(
      'INSERT INTO schedules (sId, date, schedule, place, hour, minute, isDone) VALUES (?,?,?,?,?,?,?)',
      [
        scheduleModel.sId,
        scheduleModel.date,
        scheduleModel.schedule,
        scheduleModel.place,
        scheduleModel.hour,
        scheduleModel.minute,
        scheduleModel.isDone,
      ],
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // ----------Calendar (Event)----------

  /// Desc : Event (일정) 달력에 보여주도록 형식 변경
  /// Date : 2023.06.02
  Future<Map<DateTime, dynamic>> eventLists() async {
    final Database db = await initializeDB('schedules');

    // 스케쥴 List
    final List<Map<String, Object?>> scheduleResult = await db.rawQuery(
        // "SELECT date, schedule, place, hour, minute FROM schedules ORDER BY date, hour, minute");
        "SELECT * FROM schedules ORDER BY date, hour, minute");
    List<ScheduleModel> models =
        scheduleResult.map((e) => ScheduleModel.fromMap(e)).toList();

    // date 중복 없애기
    var uniqueDate = Set<String>();
    models.where((models) => uniqueDate.add(models.date!)).toList();

    // 빈 배열 생성
    final Map<DateTime, List<Event>> eventSource = Map<DateTime, List<Event>>();

    // uniqueDate를 key로 지정 (추가)
    for (String date in uniqueDate) {
      eventSource.addAll({DateTime.parse(date): []});
    }

    // 각 uniqueDate에 해당하는 일정 할당
    for (int i = 0; i < eventSource.length; i++) {
      for (ScheduleModel model in models) {
        if (DateTime.parse(model.date.toString()) ==
            eventSource.keys.toList()[i]) {
          eventSource.values.toList()[i].add(Event(
              model.schedule.toString(),
              model.place.toString(),
              model.hour.toString(),
              model.minute.toString(),
              model.isDone));
        }
      }
    }
    return eventSource;
  }

  // --------------------------------------------------------------------------------------------------

  // Future<List<String>> queryDates() async {
  //   final Database db = await initializeSchedulesDB();
  //   List<String> list = [];
  //   final List<Map<String, Object?>> queryResult =
  //       await db.rawQuery('SELECT date FROM schedules');
  //   print(queryResult);
  //   return queryResult.map((e) => list.addAll(e).toList());
  // }

  // querySelectedSchedules(String date) async {
  //   final Database db = await initializeSchedulesDB();
  //   final List<Map> result =
  //       await db.rawQuery("SELECT * FROM schedules WHERE date=?", ["${date}"]);
  //   result.forEach((row) => print(row));
  // }

  // Future<int> insertStudents(Students student) async {
  //   int result = 0;
  //   final Database db = await initializeDB();
  //   result = await db.rawInsert(
  //     'insert into students(code, name, dept, phone) values(?,?,?,?)',
  //     [student.code, student.name, student.dept, student.phone],
  //   );

  //   return result;
  // }

  // Future<List<Students>> queryStudents() async {
  //   final Database db = await initializeDB();
  //   final List<Map<String, Object?>> queryResult =
  //       await db.rawQuery('select * from students');
  //   return queryResult.map((e) => Students.fromMap(e)).toList();
  // }

  // Future<List<Students>> selectStudent(String code) async {
  //   final Database db = await openDatabase('students.db');
  //   List<Map<String, Object?>> selectResult = await db.rawQuery(
  //       'select code, name, dept, phone from students where code = ?');
  //   return selectResult.map((e) => Students.fromMap(e)).toList();
  // }

  // Future<int> updateStudent(Students student) async {
  //   final Database db = await openDatabase('students.db');
  //   int count = await db.rawUpdate(
  //       'UPDATE students SET name = ?, dept = ?, phone = ? WHERE code = ?',
  //       [student.name, student.dept, student.phone, student.code]);
  //   return count;
  // }
}
