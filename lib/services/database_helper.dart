import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isComplete INTEGER)',
        );
      },
    );
  }

  // إدراج مهمة
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  // جلب كل المهام
  Future<List<Task>> getAllTasks() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: "id DESC",
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // تحديث مهمة
  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // حذف مهمة واحدة
  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // حذف جميع المهام المكتملة (مهمة إضافية)
  Future<int> deleteCompletedTasks() async {
    Database db = await database;
    return await db.delete('tasks', where: 'isComplete = ?', whereArgs: [1]);
  }
}
