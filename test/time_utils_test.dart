import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_2/skills/to_do/models/time_model.dart';
import 'package:jarvis_2/skills/to_do/utils/time_utils.dart';

void main() {
  DateTime now = DateTime.now();
  late Time time;

  setUp(() {
    time = Time(startDateTime: now, reccurenceGap: const Duration(days: 1));
  });

  group('stringToDate', () {
    test('correctly handles "no date"', () {
      stringToDate(time, 'go jim no date p1');
      expect(time.startDateTime, isNull);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "tod"', () {
      stringToDate(time, 'go jim tod p1');
      final expectedTime = DateTime(now.year, now.month, now.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "tom"', () {
      stringToDate(time, 'go jim tom p1');
      final expectedTime = DateTime(now.year, now.month, now.day + 1);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "12.1.2024"', () {
      stringToDate(time, 'go jim 12.1.2024 p1');
      final expectedTime = DateTime(2024, 1, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "12 jan 2024"', () {
      stringToDate(time, 'go jim 12 jan 2024 p1');
      final expectedTime = DateTime(2024, 1, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "12.1"', () {
      stringToDate(time, 'go jim 12.1 p1');
      final expectedTime = DateTime(now.year, 1, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "12 jan"', () {
      stringToDate(time, 'go jim 12 jan p1');
      final expectedTime = DateTime(now.year, 1, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "this 12"', () {
      stringToDate(time, 'go jim this 12 p1');
      final expectedTime = DateTime(now.year, now.month, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "every 12"', () {
      stringToDate(time, 'go jim every 12 p1');
      final expectedTime = DateTime(now.year, now.month, 12);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 31));
    });

    test('correctly handles "every mon/tue/wed/thu/fri/sat/sun"', () {
      stringToDate(time, 'go jim every mon p1');
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 7));
    });

    test('correctly handles "mon/tue/wed/thu/fri/sat/sun"', () {
      stringToDate(time, 'go jim mon p1');
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, null);
    });

    test('correctly handles "in 5d"', () {
      stringToDate(time, 'go jim in 5d p1');
      final in5Days = now.add(const Duration(days: 5));
      final expectedTime = DateTime(in5Days.year, in5Days.month, in5Days.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "in 5w"', () {
      stringToDate(time, 'go jim in 5w p1');
      final in5Weeks = now.add(const Duration(days: 35));
      final expectedTime =
          DateTime(in5Weeks.year, in5Weeks.month, in5Weeks.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "in 5M"', () {
      stringToDate(time, 'go jim in 5M p1');
      final in5Months = DateTime(now.year, now.month + 5, now.day);
      final expectedTime =
          DateTime(in5Months.year, in5Months.month, in5Months.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    test('correctly handles "in 5y"', () {
      stringToDate(time, 'go jim in 5y p1');
      final in5Years = DateTime(now.year + 5, now.month, now.day);
      final expectedTime =
          DateTime(in5Years.year, in5Years.month, in5Years.day);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });
  });

  group('stringToHoursMins', () {
    test('correctly handles "no time"', () {
      stringToHoursMins(time, 'go jim no time p1');
      final expectedTime = DateTime(now.year, now.month, now.day);
      expect(time.startDateTime, expectedTime);
    });

    test('correctly handles "12:00"', () {
      stringToHoursMins(time, 'go jim 12:00 p1');
      final expectedTime = DateTime(now.year, now.month, now.day, 12, 0);
      expect(time.startDateTime, expectedTime);
    });
  });

  group('stringToDateTime', () {
    // in 5m
    test('correctly handles "go jim in 5m p1"', () {
      stringToDateTime(time, 'go jim in 5m p1');
      final expectedTime =
          DateTime(now.year, now.month, now.day, now.hour, now.minute + 5);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    // in 5h
    test('correctly handles "go jim in 5h p1"', () {
      stringToDateTime(time, 'go jim in 5h p1');
      final expectedTime =
          DateTime(now.year, now.month, now.day, now.hour + 5, now.minute);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    // combination of date and time: 12 jan 24 12:00
    test('correctly handles "go jim 12 jan 24 12:00 p1"', () {
      stringToDateTime(time, 'go jim 12 jan 24 12:00 p1');
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    // combination of date and time: mon 13:59
    test('correctly handles "go jim mon 13:59 p1"', () {
      stringToDateTime(time, 'go jim mon 13:59 p1');
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 13, 59);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    // combination of date and time: in 5d 13:59
    test('correctly handles "go jim in 5d 13:59 p1"', () {
      stringToDateTime(time, 'go jim in 5d 13:59 p1');
      final in5Days = now.add(const Duration(days: 5));
      final expectedTime =
          DateTime(in5Days.year, in5Days.month, in5Days.day, 13, 59);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, isNull);
    });

    // combination of date and time: every mon 10:01
    test('correctly handles "go jim every mon 10:01 p1"', () {
      stringToDateTime(time, 'go jim every mon 10:01 p1');
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
      final expectedTime =
          DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 10, 1);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 7));
    });

    // combination of date and time: 12:00
    test('correctly handles "go jim 12:00 p1"', () {
      stringToDateTime(time, 'go jim 12:00 p1');
      final expectedTime = DateTime(now.year, now.month, now.day, 12, 0);
      expect(time.startDateTime, expectedTime);
      expect(time.reccurenceGap, const Duration(days: 1));
    });
  });

  group('stringToTime', () {
    test('correctly handles "go jim 12 jan 12:00 -> 13:00 p1"', () {
      stringToTime(time, 'go jim 12 jan 12:00 -> 13:00 p1');
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(time.startDateTime, expectedTime);
      expect(time.plannedDuration, const Duration(hours: 1));
    });

    test('correctly handles "go jim 12 jan 12:00 -> 13 jan 15:00"', () {
      stringToTime(time, 'go jim 12 jan 12:00 -> 13 jan 15:00 p1');
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(time.startDateTime, expectedTime);
      final expectedEnd = DateTime(2024, 1, 13, 15, 0);
      final duration = expectedEnd.difference(expectedTime);
      expect(time.plannedDuration, duration);
    });

    test('correctly handles "go jim 12 jan 12:00 for 1h"', () {
      stringToTime(time, 'go jim 12 jan 12:00 for 1h p1');
      final expectedTime = DateTime(2024, 1, 12, 12, 0);
      expect(time.startDateTime, expectedTime);
      expect(time.plannedDuration, const Duration(hours: 1));
    });
  });
}
