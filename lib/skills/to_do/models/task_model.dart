import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../firestore/firestore_methods.dart';
import '/skills/to_do/enums/priority_enum.dart';
import 'time_model.dart';
import 'time_period_model.dart';

class TaskFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String isDone = 'isDone';
  static const String priority = 'priority';
  static const String parentTaskId = 'parentTaskId';
  static const String subTasks = 'subTasks';
}

class Task implements Comparable<Task> {
  String id; // firebase document id
  String title;
  String description;
  bool isDone;
  Priority priority;
  Time time;
  String? parentTaskId;
  List<Task> subTasks = [];

  Task({
    this.id = '',
    this.title = '',
    this.description = '',
    this.isDone = false,
    this.priority = Priority.none,
    this.parentTaskId,
    subTasks,
    time,
  })  : time = time ?? Time(),
        subTasks = subTasks ?? [];

  TimePeriod get period => time.period;

  PickerDateRange get pickerPeriod =>
      PickerDateRange(period.plannedStart, null);

  bool get isRunning => time.isRunning;

  factory Task.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data[TaskFields.title],
      description: data[TaskFields.description],
      isDone: data[TaskFields.isDone],
      priority: Priority.values[data[TaskFields.priority]],
      time: Time.fromFirestore(data),
      parentTaskId: data[TaskFields.parentTaskId],
      subTasks:
          (data[TaskFields.subTasks] as List).map((e) => Task(id: e)).toList(),
    );
  }

  static Future<void> loadSubTasks(Task task) async {
    var futures = task.subTasks.map((e) => Firestore.getTask(e.id)).toList();

    var subTasks = await Future.wait(futures);

    task.subTasks.clear();

    task.subTasks.addAll(subTasks.where((e) => e != null).cast<Task>());
  }

  Map<String, dynamic> toFirestore() {
    return {
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.isDone: isDone,
      TaskFields.priority: priority.index,
      ...time.toFirestore(),
      TaskFields.parentTaskId: parentTaskId,
      TaskFields.subTasks: subTasks.map((e) => e.id).toList(),
    };
  }

  @override
  int compareTo(Task other) {
    return time.compareTo(other.time);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isDone == isDone &&
        other.priority == priority &&
        other.time == time &&
        other.parentTaskId == parentTaskId &&
        listEquals(other.subTasks, subTasks);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        isDone,
        priority,
        time,
        parentTaskId,
        Object.hashAll(subTasks),
      );
}
