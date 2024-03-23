import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';
import 'package:jarvis_2/skills/to_do/models/task_model.dart';
import 'package:jarvis_2/skills/to_do/models/time_model.dart';
import 'package:jarvis_2/skills/to_do/models/time_period_model.dart';

void main() {
  DateTime now = DateTime.now();
  late Time time;
  late TimePeriod period;
  late List<String> partsToDelete;

  setUp(() {
    period = TimePeriod(
        plannedStart: now,
        toOrder: true,
        plannedEnd: now.add(const Duration(days: 1)));
    time = Time(periods: [period]);
    partsToDelete = [];
  });

  group('stringToTime', () {
    test('correctly handles "go jim 12 jan 12:00 -> 13:00 p1"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 -> 13:00 p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.period.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 12, 13, 0);
      expect(task.time.period.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.period.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });

    test('correctly handles "go jim 12 jan 12:00 -> 13 jan 15:00"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 -> 13 jan 15:00 p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.period.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 13, 15, 0);
      expect(task.time.period.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.period.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });

    test('correctly handles "go jim 12 jan 12:00 for 1h"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 for 1h p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.period.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 12, 13, 0);
      expect(task.time.period.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.period.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });
  });
}
