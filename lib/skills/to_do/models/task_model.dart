import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_2/skills/to_do/methods/priority_methods.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../methods/time_methods.dart';
import '/skills/to_do/enums/priority_enum.dart';
import 'time_model.dart';
import 'time_period_model.dart';

class TaskFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String isDone = 'isDone';
  static const String priority = 'priority';
  static const String subTasks = 'subTasks';
}

class Task implements Comparable<Task> {
  String id; // firebase document id
  String title;
  String description;
  bool isDone;
  Priority priority;
  Time time;
  List<Task> subTasks = [];

  Task({
    this.id = '',
    this.title = '',
    this.description = '',
    this.isDone = false,
    this.priority = Priority.none,
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
      subTasks: (data[TaskFields.subTasks] as List)
          .map((e) => Task.fromFirestore(e))
          .toList(), // TODO optimize loading
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.isDone: isDone,
      TaskFields.priority: priority.index,
      ...time.toFirestore(),
      TaskFields.subTasks: subTasks.map((e) => e.id).toList(),
    };
  }

  void start() {
    if (time.periods[0].actualStart != null) {
      time.periods.insert(0, TimePeriod());
    }
    time.periods[0].actualStart = DateTime.now();
  }

  void stop() {
    time.periods[0].actualEnd = DateTime.now();
    if (time.reccurenceGap == null) {
      isDone = true;
      return;
    }
    time.periods.insert(0, TimePeriod());
    // TODO make the planned dates be calculated from the reccurance gap
  }

  @override
  int compareTo(Task other) {
    return time.compareTo(other.time);
  }
}
