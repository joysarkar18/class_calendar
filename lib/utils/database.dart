import 'dart:async';
import 'package:class_calender/models/class_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'classes.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Classes(id INTEGER PRIMARY KEY, subjectName TEXT, startTime TEXT, endTime TEXT, date TEXT)');
    });
  }

  Future<int> insertClass(ClassModel classModel, DateTime date) async {
    Database dbClient = await db;
    String formattedDate = "${date.year}-${date.month}-${date.day}";
    return await dbClient.insert('Classes', {
      'subjectName': classModel.subjectName,
      'startTime': classModel.startTime,
      'endTime': classModel.endTime,
      'date': formattedDate,
    });
  }

  Future<List<ClassModel>> getClassesByDate(DateTime date) async {
    Database dbClient = await db;
    String formattedDate = "${date.year}-${date.month}-${date.day}";
    List<Map> maps = await dbClient
        .query('Classes', where: "date = ?", whereArgs: [formattedDate]);

    List<ClassModel> classes = [];
    if (maps.isNotEmpty) {
      for (Map map in maps) {
        classes.add(ClassModel(
          subjectName: map['subjectName'],
          startTime: map['startTime'],
          endTime: map['endTime'],
        ));
      }
    }
    return classes;
  }

  Future<List<DateTime>> getAllDistinctDates() async {
    Database dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.rawQuery('''
      SELECT DISTINCT date FROM Classes
    ''');

    List<DateTime> dates = [];
    if (maps.isNotEmpty) {
      dates = maps.map((map) {
        List<String> dateParts = map['date'].split('-');
        return DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),
            int.parse(dateParts[2]));
      }).toList();
    }
    return dates;
  }
}
