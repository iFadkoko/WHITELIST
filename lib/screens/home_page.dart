import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

// Make the state class public to fix library_private_types_in_public_api
class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    String title = '';
    String description = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isImportant = false;
    Color selectedColor = Colors.blue;
    String repeat = 'none';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Task Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Judul Task',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => description = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showDatePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime(2000),
                                maxTime: DateTime(2100),
                                onConfirm: (date) {
                                  setState(() => selectedDate = date);
                                },
                                currentTime: selectedDate,
                                locale: LocaleType.id,
                              );
                            },
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showTimePicker(
                                context,
                                showTitleActions: true,
                                onConfirm: (time) {
                                  setState(() {
                                    selectedTime = TimeOfDay.fromDateTime(time);
                                  });
                                },
                                currentTime: DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                ),
                                locale: LocaleType.id,
                              );
                            },
                            child: Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isImportant,
                          onChanged: (value) {
                            setState(() => isImportant = value!);
                          },
                        ),
                        const Text('Penting'),
                        const Spacer(),
                        DropdownButton<Color>(
                          value: selectedColor,
                          items: [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                          ].map((color) {
                            return DropdownMenuItem<Color>(
                              value: color,
                              child: Container(
                                width: 20,
                                height: 20,
                                color: color,
                              ),
                            );
                          }).toList(),
                          onChanged: (color) {
                            setState(() => selectedColor = color!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: repeat,
                      decoration: const InputDecoration(
                        labelText: 'Pengulangan',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Tidak ada')),
                        DropdownMenuItem(value: 'daily', child: Text('Harian')),
                        DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                      ],
                      onChanged: (value) {
                        setState(() => repeat = value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      final newTask = Task(
                        title: title,
                        description: description,
                        date: selectedDate,
                        time: selectedTime,
                        isImportant: isImportant,
                        color: selectedColor,
                        repeat: repeat,
                      );
                      taskProvider.addTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    String title = task.title;
    String description = task.description;
    DateTime selectedDate = task.date;
    TimeOfDay selectedTime = task.time;
    bool isImportant = task.isImportant;
    Color selectedColor = task.color;
    String repeat = task.repeat;

    // Use controllers for editing fields to avoid deprecated 'value'
    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Judul Task',
                        border: OutlineInputBorder(),
                      ),
                      controller: titleController,
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      controller: descriptionController,
                      onChanged: (value) => description = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showDatePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime(2000),
                                maxTime: DateTime(2100),
                                onConfirm: (date) {
                                  setState(() => selectedDate = date);
                                },
                                currentTime: selectedDate,
                                locale: LocaleType.id,
                              );
                            },
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showTimePicker(
                                context,
                                showTitleActions: true,
                                onConfirm: (time) {
                                  setState(() {
                                    selectedTime = TimeOfDay.fromDateTime(time);
                                  });
                                },
                                currentTime: DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                ),
                                locale: LocaleType.id,
                              );
                            },
                            child: Text(
                              '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isImportant,
                          onChanged: (value) {
                            setState(() => isImportant = value!);
                          },
                        ),
                        const Text('Penting'),
                        const Spacer(),
                        DropdownButton<Color>(
                          value: selectedColor,
                          items: [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                          ].map((color) {
                            return DropdownMenuItem<Color>(
                              value: color,
                              child: Container(
                                width: 20,
                                height: 20,
                                color: color,
                              ),
                            );
                          }).toList(),
                          onChanged: (color) {
                            setState(() => selectedColor = color!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: repeat,
                      decoration: const InputDecoration(
                        labelText: 'Pengulangan',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Tidak ada')),
                        DropdownMenuItem(value: 'daily', child: Text('Harian')),
                        DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                      ],
                      onChanged: (value) {
                        setState(() => repeat = value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      final updatedTask = task.copyWith(
                        title: title,
                        description: description,
                        date: selectedDate,
                        time: selectedTime,
                        isImportant: isImportant,
                        color: selectedColor,
                        repeat: repeat,
                      );
                      taskProvider.updateTask(updatedTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: task.color.withOpacity(0.2), // withOpacity is deprecated, but .withValues() is not a direct replacement for opacity, so keep as is for now.
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: task.color.withOpacity(0.5), width: 1),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => taskProvider.toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: task.isImportant ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 4),
            Text(
              '${task.date.day}/${task.date.month}/${task.date.year} '
              '${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
            if (task.repeat != 'none')
              Text(
                'Berulang: ${task.repeat == 'daily' ? 'Harian' : 'Mingguan'}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.isImportant)
              const Icon(Icons.star, color: Colors.amber, size: 20),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditTaskDialog(task),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => taskProvider.deleteTask(task.id),
            ),
          ],
        ),
        onTap: () => _showEditTaskDialog(task),
      ),
    );
  }

  Widget _buildTabContent(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada task', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (taskProvider.error != null) {
              return Center(child: Text('Error: ${taskProvider.error}'));
            }
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Hari Ini'),
                    Tab(text: 'Penting'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(taskProvider.allTasks),
                      _buildTabContent(taskProvider.getTodayTasks()),
                      _buildTabContent(taskProvider.importantTasks),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}