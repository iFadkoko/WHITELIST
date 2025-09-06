import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/hive_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _allTasks = [];
  bool _isLoading = false;
  String? _error;
  bool _isHiveInitialized = false;

  List<Task> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor: langsung load tasks saat Provider dibuat
  TaskProvider() {
    loadTasks();
  }

  // Get tasks based on completion status
  List<Task> get completedTasks => _allTasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _allTasks.where((task) => !task.isCompleted).toList();
  List<Task> get importantTasks => _allTasks.where((task) => task.isImportant).toList();

  // Initialize Hive if not already initialized
  Future<void> _ensureHiveInitialized() async {
    if (!_isHiveInitialized) {
      try {
        await HiveService.init();
        _isHiveInitialized = true;
      } catch (e) {
        print('Failed to initialize Hive: $e');
        rethrow;
      }
    }
  }

  // Load all tasks from Hive
  Future<void> loadTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure Hive is initialized
      await _ensureHiveInitialized();

      // Load tasks from Hive
      _allTasks = HiveService.getAllTasks();
      
      // Sort tasks: pending first, then completed, and by date
      _allTasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.date.compareTo(b.date);
      });

      _isLoading = false;
      notifyListeners();
      
      print('Loaded ${_allTasks.length} tasks');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load tasks: $e';
      notifyListeners();
      print('Error loading tasks: $e');
    }
  }

  // Add a new task
  Future<void> addTask(Task newTask) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure Hive is initialized
      await _ensureHiveInitialized();

      // Add to Hive
      await HiveService.addTask(newTask);
      // Refresh tasks from Hive
      await loadTasks();
      print('Task added: ${newTask.title}');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add task: $e';
      notifyListeners();
      print('Error adding task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure Hive is initialized
      await _ensureHiveInitialized();

      // Update in Hive
      await HiveService.updateTask(updatedTask);
      // Refresh tasks from Hive
      await loadTasks();
      print('Task updated: ${updatedTask.title}');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update task: $e';
      notifyListeners();
      print('Error updating task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure Hive is initialized
      await _ensureHiveInitialized();

      // Delete from Hive
      await HiveService.deleteTask(id);
      // Refresh tasks from Hive
      await loadTasks();
      print('Task deleted: $id');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete task: $e';
      notifyListeners();
      print('Error deleting task: $e');
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    try {
      final task = _allTasks.firstWhere((task) => task.id == id);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    } catch (e) {
      _error = 'Failed to toggle task completion: $e';
      notifyListeners();
      print('Error toggling task completion: $e');
    }
  }

  // Toggle task importance
  Future<void> toggleTaskImportance(String id) async {
    try {
      final task = _allTasks.firstWhere((task) => task.id == id);
      final updatedTask = task.copyWith(isImportant: !task.isImportant);
      await updateTask(updatedTask);
    } catch (e) {
      _error = 'Failed to toggle task importance: $e';
      notifyListeners();
      print('Error toggling task importance: $e');
    }
  }

  // Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    try {
      return _allTasks.where((task) {
        return task.date.year == date.year &&
               task.date.month == date.month &&
               task.date.day == date.day;
      }).toList();
    } catch (e) {
      print('Error getting tasks for date: $e');
      return [];
    }
  }

  // Get tasks for today
  List<Task> getTodayTasks() {
    final today = DateTime.now();
    return getTasksForDate(DateTime(today.year, today.month, today.day));
  }

  // Get tasks for tomorrow
  List<Task> getTomorrowTasks() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getTasksForDate(DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
  }

  // Get overdue tasks (pending tasks with date before today)
  List<Task> getOverdueTasks() {
    final today = DateTime.now();
    return _allTasks.where((task) {
      return !task.isCompleted &&
             task.date.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  // Get upcoming tasks (pending tasks with date today or future)
  List<Task> getUpcomingTasks() {
    final today = DateTime.now();
    return _allTasks.where((task) {
      return !task.isCompleted &&
             !task.date.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  // Count completed tasks within a date range
  int getCompletedTasksCount(DateTime startDate, DateTime endDate) {
    try {
      // Normalize dates to compare only year, month, day
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      return _allTasks.where((task) {
        final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
        return task.isCompleted &&
               (taskDate.isAfter(normalizedStart) || taskDate.isAtSameMomentAs(normalizedStart)) &&
               (taskDate.isBefore(normalizedEnd) || taskDate.isAtSameMomentAs(normalizedEnd));
      }).length;
    } catch (e) {
      print('Error counting completed tasks: $e');
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh tasks
  Future<void> refresh() async {
    await loadTasks();
  }

  // Get task by ID
  Task? getTaskById(String id) {
    try {
      return _allTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get tasks count by completion status
  int get tasksCount => _allTasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  int get importantTasksCount => importantTasks.length;

  // Get completion percentage
  double get completionPercentage {
    if (_allTasks.isEmpty) return 0.0;
    return completedTasks.length / _allTasks.length;
  }

  // Close Hive when provider is disposed
  @override
  void dispose() {
    // Optional: Close Hive boxes if needed
    HiveService.close();
    super.dispose();
  }
}