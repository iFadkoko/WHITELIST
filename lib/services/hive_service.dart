import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class HiveService {
  static const String _tasksBoxName = 'tasksBox';
  static late Box<Task> _tasksBox;
  static bool _isInitialized = false;

  // Init Hive
  static Future<void> init() async {
    try {
      if (_isInitialized) return;
      
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);

      // Register adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }

      // Open box
      _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
      _isInitialized = true;
      
      log('Hive initialized successfully! Tasks count: ${_tasksBox.length}');
    } catch (e, st) {
      log('Error initializing Hive: $e', stackTrace: st);
      rethrow;
    }
  }

  // Check if Hive is initialized
  static void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
  }

  // Add a new task
  static Future<void> addTask(Task task) async {
    _checkInitialized();
    await _tasksBox.put(task.id, task);
    print('Task saved: ${task.id}'); // Tambahkan log ini untuk debug
  }

  // Get all tasks
  static List<Task> getAllTasks() {
    try {
      _checkInitialized();
      return _tasksBox.values.toList();
    } catch (e, st) {
      log('Error getting tasks: $e', stackTrace: st);
      return [];
    }
  }

  // Get tasks by completion status
  static List<Task> getTasksByCompletion(bool isCompleted) {
    try {
      _checkInitialized();
      return _tasksBox.values
          .where((task) => task.isCompleted == isCompleted)
          .toList();
    } catch (e, st) {
      log('Error getting tasks by completion: $e', stackTrace: st);
      return [];
    }
  }

  // Get important tasks
  static List<Task> getImportantTasks() {
    try {
      _checkInitialized();
      return _tasksBox.values
          .where((task) => task.isImportant)
          .toList();
    } catch (e, st) {
      log('Error getting important tasks: $e', stackTrace: st);
      return [];
    }
  }

  // Update a task
  static Future<void> updateTask(Task task) async {
    try {
      _checkInitialized();
      await _tasksBox.put(task.id, task);
      log('Task updated: ${task.title}');
    } catch (e, st) {
      log('Error updating task: $e', stackTrace: st);
      rethrow;
    }
  }

  // Delete a task
  static Future<void> deleteTask(String id) async {
    try {
      _checkInitialized();
      await _tasksBox.delete(id);
      log('Task deleted: $id');
    } catch (e, st) {
      log('Error deleting task: $e', stackTrace: st);
      rethrow;
    }
  }

  // Delete all tasks
  static Future<void> deleteAllTasks() async {
    try {
      _checkInitialized();
      await _tasksBox.clear();
      log('All tasks deleted');
    } catch (e, st) {
      log('Error deleting all tasks: $e', stackTrace: st);
      rethrow;
    }
  }

  // Get task by ID
  static Task? getTaskById(String id) {
    try {
      _checkInitialized();
      return _tasksBox.get(id);
    } catch (e, st) {
      log('Error getting task by ID: $e', stackTrace: st);
      return null;
    }
  }

  // Get tasks count
  static int getTasksCount() {
    try {
      _checkInitialized();
      return _tasksBox.length;
    } catch (e, st) {
      log('Error getting tasks count: $e', stackTrace: st);
      return 0;
    }
  }

  // Get completed tasks count
  static int getCompletedTasksCount() {
    try {
      _checkInitialized();
      return _tasksBox.values
          .where((task) => task.isCompleted)
          .length;
    } catch (e, st) {
      log('Error getting completed tasks count: $e', stackTrace: st);
      return 0;
    }
  }

  // Get tasks for a specific date
  static List<Task> getTasksForDate(DateTime date) {
    try {
      _checkInitialized();
      return _tasksBox.values.where((task) {
        return task.date.year == date.year &&
               task.date.month == date.month &&
               task.date.day == date.day;
      }).toList();
    } catch (e, st) {
      log('Error getting tasks for date: $e', stackTrace: st);
      return [];
    }
  }

  // Close Hive boxes
  static Future<void> close() async {
    try {
      if (_isInitialized) {
        await _tasksBox.close();
        _isInitialized = false;
        log('Hive boxes closed');
      }
    } catch (e, st) {
      log('Error closing Hive boxes: $e', stackTrace: st);
    }
  }

  // Check if Hive is ready
  static bool get isInitialized => _isInitialized;
}