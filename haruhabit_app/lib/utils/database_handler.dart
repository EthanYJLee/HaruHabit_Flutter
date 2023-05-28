import 'package:haruhabit_app/models/habit_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHandler {
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

  Future addHabit(HabitModel habitModel) async {
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
