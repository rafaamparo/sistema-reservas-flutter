import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final path = join(await getDatabasesPath(), 'booking_system.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE address(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cep TEXT NOT NULL UNIQUE,
        logradouro TEXT NOT NULL,
        bairro TEXT NOT NULL,
        localidade TEXT NOT NULL,
        uf TEXT NOT NULL,
        estado TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE property(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        address_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        number INTEGER NOT NULL,
        complement TEXT,
        price REAL NOT NULL,
        max_guest INTEGER NOT NULL,
        thumbnail TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(address_id) REFERENCES address(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        property_id INTEGER NOT NULL,
        path TEXT NOT NULL,
        FOREIGN KEY(property_id) REFERENCES property(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE booking(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        property_id INTEGER NOT NULL,
        checkin_date TEXT NOT NULL,
        checkout_date TEXT NOT NULL,
        total_days INTEGER NOT NULL,
        total_price REAL NOT NULL,
        amount_guest INTEGER NOT NULL,
        rating REAL,
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(property_id) REFERENCES property(id)
      );
    ''');
  }
}
