import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';
import 'package:jarvis_2/skills/to_do/models/time_model.dart';
import '/skills/to_do/enums/priority_enum.dart';
import 'time_period_model.dart';

class TaskFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String isDone = 'isDone';
  static const String priority = 'priority';
}

class Task {
  String id; // firebase document id
  String title;
  String description;
  bool isDone;
  Priority priority;
  Time time;

  Task({
    this.id = '',
    required this.title,
    this.description = '',
    this.isDone = false,
    this.priority = Priority.none,
    time,
  }) : time = time ?? Time();

  TimePeriod get period => time.period;

  bool get isRunning => time.isRunning;

  Task.fromInput(this.title, this.description, this.priority)
      : id = '',
        isDone = false,
        time = Time() {
    stringToTime(this);
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data[TaskFields.title],
      description: data[TaskFields.description],
      isDone: data[TaskFields.isDone],
      priority: Priority.values[data[TaskFields.priority]],
      time: Time.fromFirestore(data),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.isDone: isDone,
      TaskFields.priority: priority.index,
      ...time.toFirestore(),
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
}
