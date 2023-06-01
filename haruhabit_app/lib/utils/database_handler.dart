import 'dart:async';

import 'package:haruhabit_app/models/habit_model.dart';
import 'package:haruhabit_app/models/schedule_model.dart';
import 'package:haruhabit_app/utils/calendar_utils.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  /// Desc : "habits" Database
  /// Date : 2023.06.01

  // initialize habits DB
  Future<Database> initializeHabitsDB() async {
    String path = await getDatabasesPath();

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
  }

  // insert new habit into DB
  Future insertHabit(HabitModel habitModel) async {
    int result = 0;
    final db = await initializeHabitsDB();
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

  // read habits
  Future<List<HabitModel>> queryHabits() async {
    final Database db = await initializeHabitsDB();
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery('SELECT * FROM habits');
    return queryResult.map((e) => HabitModel.fromMap(e)).toList();
  }

  /// Desc : "schedule" Database
  /// Date : 2023.06.01

  // initialize schedules DB
  Future<Database> initializeSchedulesDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(
        path,
        'schedules.db',
      ),
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS schedules (sId INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, schedule TEXT, place TEXT, hour TEXT, minute TEXT)');
      },
      version: 1,
    );
  }

  // insert new schedule into DB
  Future insertSchedule(ScheduleModel scheduleModel) async {
    int result = 0;
    final db = await initializeSchedulesDB();
    result = await db.rawInsert(
      'INSERT INTO schedules (sId, date, schedule, place, hour, minute) VALUES (?,?,?,?,?,?)',
      [
        scheduleModel.sId,
        scheduleModel.date,
        scheduleModel.schedule,
        scheduleModel.place,
        scheduleModel.hour,
        scheduleModel.minute,
      ],
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // read schedules
  Future<List<ScheduleModel>> querySchedules() async {
    final Database db = await initializeSchedulesDB();
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery('SELECT * FROM schedules');
    return queryResult.map((e) => ScheduleModel.fromMap(e)).toList();
  }

  // Map<DateTime, dynamic> 형식으로 정제하기
  // ex. DateTime(2023, 6, 1): [
  //   Event('5분 기도하기'),
  //   Event('교회 가서 인증샷 찍기'),
  //   Event('QT하기'),
  //   Event('셀 모임하기'),
  // ],
  Future<Map<DateTime, dynamic>> eventLists() async {
    final Database db = await initializeSchedulesDB();

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

    for (String date in uniqueDate) {
      // print(date);
      eventSource.addAll({DateTime.parse(date): []});
    }

    for (int i = 0; i < eventSource.length; i++) {
      for (ScheduleModel model in models) {
        if (DateTime.parse(model.date.toString()) ==
            eventSource.keys.toList()[i]) {
          eventSource.values.toList()[i].add(Event(
              model.schedule.toString(),
              model.place.toString(),
              model.hour.toString(),
              model.minute.toString()));
        }
      }
    }
    print(eventSource);
    return eventSource;
  }

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
