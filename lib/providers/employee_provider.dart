import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/employee.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class EmployeeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Logger _logger = Logger();
  List<Employee> _employees = [];
  final List<Task> _tasks = [];
  String _searchQuery = '';
  bool _isLoggedIn = false;

  List<Employee> get employees => _searchQuery.isEmpty
      ? _employees
      : _employees
          .where((employee) =>
              employee.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              employee.prenom
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              employee.poste.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<Task> get tasks => _tasks;
  bool get isLoggedIn => _isLoggedIn;

  EmployeeProvider() {
    _loadEmployees();
  }

  void _loadEmployees() async {
    try {
      _employees =
          await _databaseService.getAllEmployees(); // Utilisation d'await ici
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading employees: $e');
    }
  }

  void addEmployee(Employee employee) {
    try {
      _databaseService.insertEmployee(employee);
      _loadEmployees();
    } catch (e) {
      _logger.e('Error adding employee: $e');
    }
  }

  void updateEmployee(Employee employee) {
    try {
      _databaseService.updateEmployee(employee);
      _loadEmployees();
    } catch (e) {
      _logger.e('Error updating employee: $e');
    }
  }

  void deleteEmployee(String id) {
    try {
      _databaseService.deleteEmployee(id);
      _loadEmployees();
    } catch (e) {
      _logger.e('Error deleting employee: $e');
    }
  }

  void searchEmployees(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool login(String username, String password) {
    if (username == 'admin' && password == 'admin123') {
      _isLoggedIn = true;
      _loadEmployees();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _searchQuery = '';
    notifyListeners();
  }

  void addTask(Task task) {
    try {
      _databaseService.insertTask(task);
      notifyListeners();
    } catch (e) {
      _logger.e('Error adding task: $e');
    }
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    try {
      return await _databaseService
          .getTasksForDate(date); // Utilisation d'await ici
    } catch (e) {
      _logger.e('Error getting tasks for date: $e');
      return [];
    }
  }

  Future<List<Task>> getTasksForEmployee(String employeeId) async {
    try {
      return await _databaseService
          .getTasksForEmployee(employeeId); // Utilisation d'await ici
    } catch (e) {
      _logger.e('Error getting tasks for employee: $e');
      return [];
    }
  }

  void updateTask(Task task) {
    try {
      _databaseService.updateTask(task);
      notifyListeners();
    } catch (e) {
      _logger.e('Error updating task: $e');
    }
  }

  void deleteTask(String id) {
    try {
      _databaseService.deleteTask(id);
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting task: $e');
    }
  }
}
