import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_flutter/data/todo.dart';

class DatabaseHelper {
  static const _databaseName = "todo.db";
  static const _databaseVersion = 1;
  static const todoTable = "todo";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // https://stackoverflow.com/a/67053311/7703502
  // Resolve to Database doesn't allow null
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $todoTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date INTEGER DEFAULT 0,
      title String,
      memo String,
      color INTEGER,
      done INTEGER,
      category String
    )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<int> insertTodo(Todo todo) async {
    Database db = await instance.database;

    if (todo.id == null) {
      // 새로 추가
      Map<String, dynamic> row = {
        "title": todo.title,
        "date": todo.date,
        "memo": todo.memo,
        "color": todo.color,
        "done": todo.done,
        "category": todo.category,
      };

      return await db.insert(todoTable, row);
    } else {
      Map<String, dynamic> row = {
        "title": todo.title,
        "date": todo.date,
        "memo": todo.memo,
        "color": todo.color,
        "done": todo.done,
        "category": todo.category,
      };

      return await db.update(todoTable, row, where: "id = ?", whereArgs: [todo.id]);
    }
  }

  Future<List<Todo>> getAllTodo() async {
    Database db = await instance.database;
    List<Todo> todos = [];

    var queries = await db.query(todoTable);

    for (var q in queries) {
      todos.add(
        Todo(
          // sql database 에서 받아오는 결과는 object 로 인식되어 원하는 type 로 재설정해줄 것
          id: int.parse(q["id"].toString()),
          title: q["title"].toString(),
          date: int.parse(q["date"].toString()),
          memo: q["memo"].toString(),
          color: int.parse(q["color"].toString()),
          done: int.parse(q["done"].toString()),
          category: q["category"].toString(),
        ),
      );
    }

    return todos;
  }

  Future<List<Todo>> getTodoByDate(int date) async {
    Database db = await instance.database;
    List<Todo> todos = [];

    var queries = await db.query(todoTable, where: "date = ?", whereArgs: [date]);

    for (var q in queries) {
      todos.add(
        Todo(
          id: int.parse(q["id"].toString()),
          title: q["title"].toString(),
          date: int.parse(q["date"].toString()),
          memo: q["memo"].toString(),
          color: int.parse(q["color"].toString()),
          done: int.parse(q["done"].toString()),
          category: q["category"].toString(),
        ),
      );
    }

    return todos;
  }
}
