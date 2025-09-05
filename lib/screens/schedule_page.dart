import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Color palette for anime-inspired theme
  final List<Color> _calendarColors = [
    const Color(0xFFFF9AA2), // Pastel pink
    const Color(0xFFFFB7B2), // Light coral
    const Color(0xFFFFDAC1), // Peach
    const Color(0xFFE2F0CB), // Light green
    const Color(0xFFB5EAD7), // Mint
    const Color(0xFFC7CEEA), // Periwinkle
    const Color(0xFFF8B195), // Salmon
    const Color(0xFFF67280), // Coral
    const Color(0xFF6C5B7B), // Purple
    const Color(0xFF355C7D), // Navy blue
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Task> _getTasksForDay(DateTime day) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return taskProvider.getTasksForDate(day);
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> groupedTasks = {};
    for (final task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      groupedTasks.putIfAbsent(date, () => []).add(task);
    }
    return groupedTasks;
  }

  void _showAddTaskDialog(DateTime selectedDate) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    String title = '';
    String description = '';
    DateTime pickedDate = selectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isImportant = false;
    Color selectedColor = _calendarColors[1]; // Use one of our theme colors
    String repeat = 'none';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Anime-style header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _calendarColors[3],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Tambah Task Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Judul Task',
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                        ),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.description, color: Colors.deepPurple),
                        ),
                        onChanged: (value) => description = value,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: pickedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.deepPurple,
                                          onPrimary: Colors.white,
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setStateDialog(() {
                                    pickedDate = picked;
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time, size: 16),
                              label: Text(
                                '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.deepPurple,
                                          onPrimary: Colors.white,
                                        ),
                                        dialogBackgroundColor: Colors.white,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setStateDialog(() {
                                    selectedTime = picked;
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: isImportant,
                              onChanged: (value) {
                                setStateDialog(() => isImportant = value!);
                              },
                              activeColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const Text('⭐ Penting', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: selectedColor),
                            ),
                            child: DropdownButton<Color>(
                              value: selectedColor,
                              underline: const SizedBox(),
                              items: _calendarColors.map((color) {
                                return DropdownMenuItem<Color>(
                                  value: color,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (color) {
                                setStateDialog(() => selectedColor = color!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: repeat,
                        decoration: InputDecoration(
                          labelText: 'Pengulangan',
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.repeat, color: Colors.deepPurple),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('Tidak ada')),
                          DropdownMenuItem(value: 'daily', child: Text('Harian')),
                          DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                        ],
                        onChanged: (value) {
                          setStateDialog(() => repeat = value!);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.deepPurple),
                            ),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (title.isNotEmpty) {
                                final newTask = Task(
                                  title: title,
                                  description: description,
                                  date: pickedDate,
                                  time: selectedTime,
                                  isImportant: isImportant,
                                  color: selectedColor,
                                  repeat: repeat,
                                );
                                taskProvider.addTask(newTask);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventMarker(int taskCount) {
    if (taskCount == 0) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarColors[taskCount % _calendarColors.length],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      width: 8,
      height: 8,
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada task untuk tanggal ini',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan task baru dengan menekan tombol +',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: task.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: task.color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                  taskProvider.toggleTaskCompletion(task.id);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: task.color,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                fontWeight: task.isImportant ? FontWeight.bold : FontWeight.normal,
                color: task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey : Colors.black54,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: task.color),
                    const SizedBox(width: 4),
                    Text(
                      '${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: task.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.isImportant)
                  const Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.allTasks;
    final tasksByDate = _groupTasksByDate(allTasks);

    return Column(
      children: [
        // Calendar Card with anime-inspired design
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _calendarColors[2].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => tasksByDate[DateTime(day.year, day.month, day.day)] ?? [],
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: _calendarColors[0],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: _calendarColors[3],
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.pink),
                holidayTextStyle: const TextStyle(color: Colors.purple),
                defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
                outsideTextStyle: TextStyle(color: Colors.grey[400]),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: _calendarColors[4],
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                headerPadding: const EdgeInsets.symmetric(vertical: 12),
                titleTextStyle: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                weekendStyle: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  return events.isNotEmpty ? _buildEventMarker(events.length) : null;
                },
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSameDay(day, DateTime.now()) 
                        ? _calendarColors[9].withOpacity(0.1) 
                        : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: isSameDay(day, DateTime.now())
                            ? _calendarColors[9]
                            : null,
                          fontWeight: isSameDay(day, DateTime.now())
                            ? FontWeight.bold
                            : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Task Header with Add Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDay != null
                    ? 'Task untuk ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                    : 'Pilih tanggal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Task'),
                onPressed: () {
                  if (_selectedDay != null) {
                    _showAddTaskDialog(_selectedDay!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calendarColors[3],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Task List
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _selectedDay != null
                ? _buildTaskList(_getTasksForDay(_selectedDay!))
                : Center(
                    child: Text(
                      'Pilih tanggal untuk melihat task',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}