import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Load tasks on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskProvider.loadTasks();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskProvider.refresh(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.error != null) {
            return Center(
              child: Text('Error: ${taskProvider.error}'),
            );
          }

          return ListView.builder(
            itemCount: taskProvider.allTasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.allTasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text(task.description),
                leading: Icon(
                  task.isImportant ? Icons.star : Icons.star_border,
                  color: task.isImportant ? Colors.amber : Colors.grey,
                ),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => taskProvider.toggleTaskCompletion(task.id),
                ),
                onTap: () {
                  // Navigate to edit screen
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
          final newTask = Task(
            title: 'New Task',
            description: 'Task description',
            date: DateTime.now(),
            time: TimeOfDay.now(),
          );
          taskProvider.addTask(newTask);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}