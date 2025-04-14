import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/job.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'job_board.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        print('Creating new database with version $version');
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            imagePath TEXT,
            isAdmin INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            company TEXT,
            location TEXT,
            description TEXT,
            requirements TEXT,
            salary TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            company TEXT,
            location TEXT,
            description TEXT,
            requirements TEXT,
            salary TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_admins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            imagePath TEXT
          )
        ''');
        // Insert permanent admin
        await db.insert(
          'users',
          User(
            name: 'Saleh',
            email: 'saleh@gmail.com',
            password: 'saleh',
            isAdmin: true,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Database created with all tables');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 2) {
          try {
            // Check if isAdmin column exists in users table
            var pragma = await db.rawQuery('PRAGMA table_info(users)');
            bool hasIsAdmin = pragma.any((column) => column['name'] == 'isAdmin');
            if (!hasIsAdmin) {
              await db.execute('ALTER TABLE users ADD COLUMN isAdmin INTEGER DEFAULT 0');
              print('Added isAdmin column to users table');
            }

            // Check if pending_jobs table exists
            var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='pending_jobs'");
            if (tables.isEmpty) {
              await db.execute('''
                CREATE TABLE pending_jobs (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT,
                  company TEXT,
                  location TEXT,
                  description TEXT,
                  requirements TEXT,
                  salary TEXT
                )
              ''');
              print('Created pending_jobs table');
            }

            // Check if pending_admins table exists
            tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='pending_admins'");
            if (tables.isEmpty) {
              await db.execute('''
                CREATE TABLE pending_admins (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT,
                  email TEXT UNIQUE,
                  password TEXT,
                  imagePath TEXT
                )
              ''');
              print('Created pending_admins table');
            }

            // Ensure permanent admin exists
            final existingAdmin = await db.query(
              'users',
              where: 'email = ?',
              whereArgs: ['alif@gmail.com'],
            );
            if (existingAdmin.isEmpty) {
              await db.insert(
                'users',
                User(
                  name: 'Alif',
                  email: 'alif@gmail.com',
                  password: 'alif',
                  isAdmin: true,
                ).toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
              print('Inserted permanent admin');
            }
          } catch (e) {
            print('Error during migration: $e');
          }
        }
        print('Database upgrade completed');
      },
      onOpen: (db) async {
        print('Database opened');
        // Log table info for debugging
        var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        print('Tables in database: $tables');
        var userColumns = await db.rawQuery('PRAGMA table_info(users)');
        print('Users table columns: $userColumns');
        var pendingAdminsColumns = await db.rawQuery('PRAGMA table_info(pending_admins)');
        print('Pending_admins table columns: $pendingAdminsColumns');
      },
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertJob(Job job) async {
    final db = await database;
    await db.insert('jobs', job.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Job>> getJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jobs');
    return List.generate(maps.length, (i) => Job.fromMap(maps[i]));
  }

  Future<void> deleteJob(int id) async {
    final db = await database;
    await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertPendingJob(Job job) async {
    final db = await database;
    await db.insert('pending_jobs', job.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Job>> getPendingJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pending_jobs');
    return List.generate(maps.length, (i) => Job.fromMap(maps[i]));
  }

  Future<void> deletePendingJob(int id) async {
    final db = await database;
    await db.delete('pending_jobs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertPendingAdmin(User user) async {
    final db = await database;
    // Exclude isAdmin since pending_admins table doesn't have this column
    final map = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'imagePath': user.imagePath,
    };
    print('Inserting into pending_admins: $map');
    await db.insert('pending_admins', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getPendingAdmins() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pending_admins');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<void> deletePendingAdmin(int id) async {
    final db = await database;
    await db.delete('pending_admins', where: 'id = ?', whereArgs: [id]);
  }
}