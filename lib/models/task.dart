import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  final int _hour; // Simpan hour sebagai int

  @HiveField(6)
  final int _minute; // Simpan minute sebagai int

  @HiveField(7)
  bool isImportant;

  @HiveField(8)
  final int colorValue; // Simpan color sebagai int

  @HiveField(9)
  String repeat;

  /// 🔹 Konstruktor utama (dipakai di UI manual)
  Task({
  String? id,
  required this.title,
  this.description = '',
  this.isCompleted = false,
  required DateTime date,
  TimeOfDay? time, // ❌ tidak wajib
  this.isImportant = false,
  Color color = Colors.blue,
  this.repeat = 'none',
})  : id = id ?? const Uuid().v4(),
      date = DateTime(date.year, date.month, date.day),
      _hour = time?.hour ?? 0,
      _minute = time?.minute ?? 0,
      colorValue = color.value;

  /// 🔹 Konstruktor khusus Hive (biar task.g.dart gak error)
  Task.hive({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.date,
    required int hour,
    required int minute,
    this.isImportant = false,
    required this.colorValue,
    this.repeat = 'none',
  })  : _hour = hour,
        _minute = minute;

  // Getter untuk TimeOfDay
  TimeOfDay get time => TimeOfDay(hour: _hour, minute: _minute);

  // Getter untuk Color
  Color get color => Color(colorValue);

  // Factory method untuk create Task dari Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: map['timeHour'],
        minute: map['timeMinute'],
      ),
      isImportant: map['isImportant'] ?? false,
      color: Color(map['colorValue']),
      repeat: map['repeat'] ?? 'none',
    );
  }

  // Convert Task ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'timeHour': _hour,
      'timeMinute': _minute,
      'isImportant': isImportant,
      'colorValue': colorValue,
      'repeat': repeat,
    };
  }

  // CopyWith untuk update sebagian data
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? date,
    TimeOfDay? time,
    bool? isImportant,
    Color? color,
    String? repeat,
  }) {
    return Task(
      id: id, // ID tidak berubah
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      time: time ?? this.time,
      isImportant: isImportant ?? this.isImportant,
      color: color ?? this.color,
      repeat: repeat ?? this.repeat,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
