import 'package:cloud_firestore/cloud_firestore.dart';
import '/skills/to_do/enums/priority_enum.dart';

class TaskFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String priority = 'priority';
}

class Task {
  String id;
  String title;
  String? description;
  DateTime? startTime;
  DateTime? endTime;
  Priority priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.priority = Priority.none,
  });

  Task.create({
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.priority = Priority.none,
  }) : id = '';

  factory Task.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data[TaskFields.title],
      description: data[TaskFields.description],
      startTime: (data[TaskFields.startTime] as Timestamp?)?.toDate(),
      endTime: (data[TaskFields.endTime] as Timestamp?)?.toDate(),
      priority: Priority.values[data['priority'] ?? Priority.none.index],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.startTime: startTime,
      TaskFields.endTime: endTime,
      TaskFields.priority: priority.index,
    };
  }
}
