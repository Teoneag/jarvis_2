import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';
import 'package:jarvis_2/skills/to_do/models/task_model.dart';
import 'package:jarvis_2/skills/to_do/models/time_model.dart';

void main() {
  DateTime now = DateTime.now();
  late Time time;
  late List<String> partsToDelete;

  setUp(() {
    time = Time(
        plannedStart: now,
        toOrder: true,
        plannedEnd: now.add(const Duration(days: 1)));
    partsToDelete = [];
  });

  group('stringToDate', () {
    test('correctly handles "no date"', () {
      stringToDate(time, 'go jim no date p1', partsToDelete);
      expect(time.plannedStart, isNull);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['no date']);
    });

    test('correctly handles "tod"', () {
      stringToDate(time, 'go jim tod p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, now.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['tod']);
    });

    test('correctly handles "tom"', () {
      stringToDate(time, 'go jim tom p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, now.day + 1);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['tom']);
    });

    test('correctly handles "12.1.2024"', () {
      stringToDate(time, 'go jim 12.1.2024 p1', partsToDelete);
      final expectedTime = DateTime(2024, 1, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['12.1.2024']);
    });

    test('correctly handles "12 jan 2024"', () {
      stringToDate(time, 'go jim 12 jan 2024 p1', partsToDelete);
      final expectedTime = DateTime(2024, 1, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['12 jan 2024']);
    });

    test('correctly handles "12.1"', () {
      stringToDate(time, 'go jim 12.1 p1', partsToDelete);
      final expectedTime = DateTime(now.year, 1, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['12.1']);
    });

    test('correctly handles "12 jan"', () {
      stringToDate(time, 'go jim 12 jan p1', partsToDelete);
      final expectedTime = DateTime(now.year, 1, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['12 jan']);
    });

    test('correctly handles "this 12"', () {
      stringToDate(time, 'go jim this 12 p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['this 12']);
    });

    test('correctly handles "every 12"', () {
      stringToDate(time, 'go jim every 12 p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, 12);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 31));
      expect(partsToDelete, ['every 12']);
    });

    test('correctly handles "every mon/tue/wed/thu/fri/sat/sun"', () {
      stringToDate(time, 'go jim every mon p1', partsToDelete);
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 7));
      expect(partsToDelete, ['every mon']);
    });

    test('correctly handles "mon/tue/wed/thu/fri/sat/sun"', () {
      stringToDate(time, 'go jim mon p1', partsToDelete);
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, null);
      expect(partsToDelete, ['mon']);
    });

    test('correctly handles "in 5d"', () {
      stringToDate(time, 'go jim in 5d p1', partsToDelete);
      final in5Days = now.add(const Duration(days: 5));
      final expectedTime = DateTime(in5Days.year, in5Days.month, in5Days.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5d']);
    });

    test('correctly handles "in 5w"', () {
      stringToDate(time, 'go jim in 5w p1', partsToDelete);
      final in5Weeks = now.add(const Duration(days: 35));
      final expectedTime =
          DateTime(in5Weeks.year, in5Weeks.month, in5Weeks.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5w']);
    });

    test('correctly handles "in 5M"', () {
      stringToDate(time, 'go jim in 5M p1', partsToDelete);
      final in5Months = DateTime(now.year, now.month + 5, now.day);
      final expectedTime =
          DateTime(in5Months.year, in5Months.month, in5Months.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5M']);
    });

    test('correctly handles "in 5y"', () {
      stringToDate(time, 'go jim in 5y p1', partsToDelete);
      final in5Years = DateTime(now.year + 5, now.month, now.day);
      final expectedTime =
          DateTime(in5Years.year, in5Years.month, in5Years.day);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5y']);
    });
  });

  group('stringToHoursMins', () {
    test('correctly handles "no time"', () {
      stringToHoursMins(time, 'go jim no time p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, now.day);
      expect(time.plannedStart, expectedTime);
    });

    test('correctly handles "12:00"', () {
      stringToHoursMins(time, 'go jim 12:00 p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, now.day, 12, 0);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, null);
      expect(partsToDelete, ['12:00']);
    });
  });

  group('stringToDateTime', () {
    // in 5m
    test('correctly handles "go jim in 5m p1"', () {
      stringToDateTime(time, 'go jim in 5m p1', partsToDelete);
      final expectedTime =
          DateTime(now.year, now.month, now.day, now.hour, now.minute + 5);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5m']);
    });

    // in 5h
    test('correctly handles "go jim in 5h p1"', () {
      stringToDateTime(time, 'go jim in 5h p1', partsToDelete);
      final expectedTime =
          DateTime(now.year, now.month, now.day, now.hour + 5, now.minute);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5h']);
    });

    // combination of date and time: 12 jan 24 12:00
    test('correctly handles "go jim 12 jan 2024 12:00 p1"', () {
      stringToDateTime(time, 'go jim 12 jan 2024 12:00 p1', partsToDelete);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['12 jan 2024', '12:00']);
    });

    // combination of date and time: mon 13:59
    test('correctly handles "go jim mon 13:59 p1"', () {
      stringToDateTime(time, 'go jim mon 13:59 p1', partsToDelete);
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 13, 59);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['mon', '13:59']);
    });

    // combination of date and time: in 5d 13:59
    test('correctly handles "go jim in 5d 13:59 p1"', () {
      stringToDateTime(time, 'go jim in 5d 13:59 p1', partsToDelete);
      final in5Days = now.add(const Duration(days: 5));
      final expectedTime =
          DateTime(in5Days.year, in5Days.month, in5Days.day, 13, 59);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, isNull);
      expect(partsToDelete, ['in 5d', '13:59']);
    });

    // combination of date and time: every mon 10:01
    test('correctly handles "go jim every mon 10:01 p1"', () {
      stringToDateTime(time, 'go jim every mon 10:01 p1', partsToDelete);
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 10, 1);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 7));
      expect(partsToDelete, ['every mon', '10:01']);
    });

    // combination of date and time: 12:00
    test('correctly handles "go jim 12:00 p1"', () {
      stringToDateTime(time, 'go jim 12:00 p1', partsToDelete);
      final expectedTime = DateTime(now.year, now.month, now.day, 12, 0);
      expect(time.plannedStart, expectedTime);
      expect(time.reccurenceGap, null);
      expect(partsToDelete, ['12:00']);
    });
  });

  group('stringToTime', () {
    test('correctly handles "go jim 12 jan 12:00 -> 13:00 p1"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 -> 13:00 p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 12, 13, 0);
      expect(task.time.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });

    test('correctly handles "go jim 12 jan 12:00 -> 13 jan 15:00"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 -> 13 jan 15:00 p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 13, 15, 0);
      expect(task.time.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });

    test('correctly handles "go jim 12 jan 12:00 for 1h"', () {
      Task task = Task(title: 'go jim 12 jan 12:00 for 1h p1');
      stringToTime(task);
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(task.time.plannedStart, expectedTime);
      final expectedEnd = DateTime(2024, 1, 12, 13, 0);
      expect(task.time.plannedEnd, expectedEnd);
      expect(task.time.reccurenceGap, isNull);
      expect(task.time.toOrder, isFalse);
      expect(task.title, 'go jim p1');
    });
  });
}
