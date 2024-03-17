import 'package:intl/intl.dart';
import 'package:jarvis_2/skills/to_do/models/time_model.dart';

final now = DateTime.now();

String dateToString(DateTime date, int daysDiff, bool includeTime) {
  if (daysDiff == 0) {
    return includeTime ? DateFormat('HH:mm').format(date) : 'tod';
  } else if (daysDiff == 1) {
    return includeTime ? 'tom ${DateFormat('HH:mm').format(date)}' : 'tom';
  } else if (daysDiff <= 7) {
    return DateFormat(includeTime ? 'EEE HH:mm' : 'EEE').format(date);
  } else if (daysDiff <= 365) {
    return DateFormat(includeTime ? 'd MMM HH:mm' : 'd MMM').format(date);
  } else {
    return DateFormat(includeTime ? 'd MMM yyyy HH:mm' : 'd MMM yyyy')
        .format(date);
  }
}

String dateToStringShort(DateTime? start, bool toOrder, Duration? duration) {
  if (start == null) return '';

  final daysDiff = substractDays(start, DateTime.now());

  String res = '';

  res += dateToString(start, daysDiff, true);

  if (duration == null) return res;

  final endDaysDiff = duration.inDays;
  final endDate = start.add(duration);

  res += ' -> ${dateToString(endDate, endDaysDiff, true)}';

  return res;
}

void stringToTime(Time time, String input) {
  // modifies everything

  // 12 jan 12:00 -> 13:00
  if (input.contains('->')) {
    List<String> parts = input.split('->');
    stringToDateTime(time, parts[0]);
    stringToHoursMins(time, parts[0]);
    Time end = Time.copy(time);
    stringToDateTime(end, parts[1]);
    stringToHoursMins(end, parts[1]);
    time.plannedDuration = end.startDateTime!.difference(time.startDateTime!);
    return;
  }

  // 21 jan 12:00 for 1m/h/d/w/M/y
  if (input.contains('for')) {
    List<String> parts = input.split('for');
    stringToDateTime(time, parts[0]);
    stringToHoursMins(time, parts[0]);

    Match? match = RegExp(r'(\d+)([mhdywMy])').firstMatch(parts[1]);
    if (match != null) {
      int number = int.parse(match.group(1)!);
      String unit = match.group(2)!;
      switch (unit) {
        case 'm':
          time.plannedDuration = Duration(minutes: number);
          break;
        case 'h':
          time.plannedDuration = Duration(hours: number);
          break;
        case 'd':
          time.plannedDuration = Duration(days: number);
          break;
        case 'w':
          time.plannedDuration = Duration(days: number * 7);
          break;
        case 'M':
          time.plannedDuration = Duration(days: number * 31);
          break;
        case 'y':
          time.plannedDuration = Duration(days: number * 365);
          break;
      }
    }
    return;
  }
}

void stringToDateTime(Time time, String input) {
  // modifies startDateTime, reccurenceGap, toOrder

  // in 5m/h
  Match? match = RegExp(r'in (\d+)([mh])').firstMatch(input);
  if (match != null) {
    int number = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    switch (unit) {
      case 'm':
        time.startDateTime = DateTime(
            now.year, now.month, now.day, now.hour, now.minute + number);
        break;
      case 'h':
        time.startDateTime = DateTime(
            now.year, now.month, now.day, now.hour + number, now.minute);
        break;
    }

    time.toOrder = true;
    time.reccurenceGap = null;

    return;
  }

  stringToDate(time, input);
  if (time.startDateTime == null) {
    time.startDateTime = DateTime(now.year, now.month, now.day);
    time.reccurenceGap = null;
  }
  stringToHoursMins(time, input);
}

void stringToHoursMins(Time time, String input) {
  // only modifies startDateTime

  // no time
  if (input.contains('no time')) {
    time.startDateTime = DateTime(time.startDateTime!.year,
        time.startDateTime!.month, time.startDateTime!.day);
    return;
  }

  // 12:34
  Match? match = RegExp(r"\b(\d{1,2}):(\d{2})").firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split(':');
    time.startDateTime = DateTime(
        time.startDateTime!.year,
        time.startDateTime!.month,
        time.startDateTime!.day,
        int.parse(parts[0]),
        int.parse(parts[1]));
    return;
  }
}

void stringToDate(Time time, String input) {
  // only modifies startDateTime, reccuranceGap
  // TODO highlight what part of the input is converted to date
  Match? match;

  // no date
  if (input.contains('no date')) {
    time.startDateTime = null;
    time.reccurenceGap = null;
    return;
  }

  // tod/tom
  if (input.contains('tod')) {
    time.startDateTime = DateTime(now.year, now.month, now.day);
    time.reccurenceGap = null;
    return;
  }
  if (input.contains('tom')) {
    time.startDateTime = DateTime(now.year, now.month, now.day + 1);
    time.reccurenceGap = null;
    return;
  }

  // 12.1.2024
  match = RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])\.\d{4}")
      .firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split('.');
    time.startDateTime =
        DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12 jan 2024
  match = RegExp(
    r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s\d{4}",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split(' ');
    time.startDateTime = DateTime(int.parse(parts[2]),
        monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12.1
  match =
      RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])").firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split('.');
    time.startDateTime =
        DateTime(now.year, int.parse(parts[1]), int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12 jan
  match = RegExp(
    r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split(' ');
    time.startDateTime = DateTime(
        now.year, monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // this 12
  match = RegExp(
    r"this\s(3[01]|[12][0-9]|[1-9])",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split(' ');
    time.startDateTime = DateTime(now.year, now.month, int.parse(parts[1]));
    time.reccurenceGap = null;
    return;
  }

  // every 12
  match = RegExp(
    r"every\s(3[01]|[12][0-9]|[1-9])",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    List<String> parts = match.group(0)!.split(' ');
    time.startDateTime = DateTime(now.year, now.month, int.parse(parts[1]));
    time.reccurenceGap = const Duration(days: 31);
    return;
  }

  // every mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"every\s(mon|tue|wed|thu|fri|sat|sun)",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    int day = weekDayMap[match.group(1)!]!;
    int daysDiff = day - now.weekday;
    if (daysDiff <= 0) daysDiff += 7;
    final nextWekkDay = now.add(Duration(days: daysDiff));
    time.startDateTime =
        DateTime(nextWekkDay.year, nextWekkDay.month, nextWekkDay.day);
    time.reccurenceGap = const Duration(days: 7);
    return;
  }

  // mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"(mon|tue|wed|thu|fri|sat|sun)",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    int day = weekDayMap[match.group(0)!]!;
    int daysDiff = day - now.weekday;
    if (daysDiff <= 0) daysDiff += 7;
    final nextWeekDay = now.add(Duration(days: daysDiff));
    time.startDateTime =
        DateTime(nextWeekDay.year, nextWeekDay.month, nextWeekDay.day);
    time.reccurenceGap = null;
    return;
  }

  // in 5d/w/M/y
  match = RegExp(r'in (\d+)([dwMy])').firstMatch(input);
  if (match != null) {
    int number = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    switch (unit) {
      case 'd':
        time.startDateTime = DateTime(now.year, now.month, now.day + number);
        break;
      case 'w':
        time.startDateTime =
            DateTime(now.year, now.month, now.day + number * 7);
        break;
      case 'M':
        time.startDateTime = DateTime(now.year, now.month + number, now.day);
        break;
      case 'y':
        time.startDateTime = DateTime(now.year + number, now.month, now.day);
        break;
    }

    time.toOrder = true;
    time.reccurenceGap = null;

    return;
  }

  return;
}

int substractDays(DateTime d1, DateTime d2) {
  DateTime truncD1 = DateTime(d1.year, d1.month, d1.day);
  DateTime truncD2 = DateTime(d2.year, d2.month, d2.day);
  return truncD2.difference(truncD1).inDays;
}

Map<String, int> monthMap = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

Map<String, int> weekDayMap = {
  'mon': 1,
  'tue': 2,
  'wed': 3,
  'thu': 4,
  'fri': 5,
  'sat': 6,
  'sun': 7,
};
