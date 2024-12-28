import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import '../models/employee.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'employee_management.db');
      _logger.d('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      _logger.e('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables...');
    await db.execute('''
      CREATE TABLE employees(
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT NOT NULL,
        telephone TEXT NOT NULL,
        poste TEXT NOT NULL,
        departement TEXT NOT NULL,
        dateEmbauche TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        employeeId TEXT NOT NULL,
        employeeName TEXT NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employees (id)
      )
    ''');

    _logger.i('Database tables created successfully');
  }

  // Employee methods
  Future<void> insertEmployee(Employee employee) async {
    final db = await database;
    try {
      _logger.i('Inserting employee: ${employee.nom} ${employee.prenom}');
      await db.insert(
        'employees',
        employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.i('Employee inserted successfully');
    } catch (e) {
      _logger.e('Error inserting employee: $e');
      rethrow;
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    try {
      _logger.i('Fetching all employees...');
      final result = await db.query('employees');
      return result.map((row) => Employee.fromMap(row)).toList();
    } catch (e) {
      _logger.e('Error fetching employees: $e');
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await database;
    try {
      _logger.i('Updating employee: ${employee.nom} ${employee.prenom}');
      await db.update(
        'employees',
        employee.toMap(),
        where: 'id = ?',
        whereArgs: [employee.id],
      );
      _logger.i('Employee updated successfully');
    } catch (e) {
      _logger.e('Error updating employee: $e');
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    final db = await database;
    try {
      _logger.i('Deleting employee with id: $id');
      await db.delete(
        'employees',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Employee deleted successfully');
    } catch (e) {
      _logger.e('Error deleting employee: $e');
      rethrow;
    }
  }

  // Task methods (similar to Employee)
  Future<void> insertTask(Task task) async {
    final db = await database;
    try {
      _logger.i('Inserting task: ${task.title}');
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.i('Task inserted successfully');
    } catch (e) {
      _logger.e('Error inserting task: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database; // Attendre l'instance de la base de données
    final startOfDay =
        DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    try {
      final result = await db.rawQuery(
        'SELECT * FROM tasks WHERE date BETWEEN ? AND ?',
        [startOfDay, endOfDay],
      );

      return result.map((row) => Task.fromMap(row)).toList();
    } catch (e) {
      _logger.e('Error getting tasks: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasksForEmployee(String employeeId) async {
    final db = await database; // Attendre l'instance de la base de données
    try {
      final result = await db.rawQuery(
        'SELECT * FROM tasks WHERE employeeId = ?',
        [employeeId],
      );

      return result.map((row) => Task.fromMap(row)).toList();
    } catch (e) {
      _logger.e('Error getting tasks for employee: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    final db = await database; // Attendre l'instance de la base de données
    try {
      await db.rawUpdate(
        'UPDATE tasks SET title = ?, description = ?, date = ?, isCompleted = ?, employeeId = ?, employeeName = ? WHERE id = ?',
        [
          task.title,
          task.description,
          task.date.toIso8601String(),
          task.isCompleted ? 1 : 0,
          task.employeeId,
          task.employeeName,
          task.id,
        ],
      );
      _logger.i('Task updated successfully');
    } catch (e) {
      _logger.e('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final db = await database; // Attendre l'instance de la base de données
    try {
      await db.rawDelete(
        'DELETE FROM tasks WHERE id = ?',
        [id],
      );
      _logger.i('Task deleted successfully');
    } catch (e) {
      _logger.e('Error deleting task: $e');
      rethrow;
    }
  }
}
