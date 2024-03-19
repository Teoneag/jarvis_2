import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/skills/to_do/models/task_model.dart';
import '/skills/to_do/models/time_model.dart';

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

Widget? timeToShortWidget(Time time) {
  String res = timeToShortString(time);
  if (res == '') return null;
  if (time.reccurenceGap == null) return Text(res);
  return Row(
    children: [
      Text(res),
      const SizedBox(width: 5),
      const Icon(Icons.sync, size: 15),
    ],
  );
}

String timeToShortString(Time time) {
  if (time.period.plannedStart == null) return '';

  final daysDiff = substractDays(time.period.plannedStart!, DateTime.now());

  String res = '';

  res +=
      dateToString(time.period.plannedStart!, daysDiff, !time.period.toOrder);

  if (time.period.plannedEnd == null) return res;

  final endDaysDiff =
      time.period.plannedEnd!.difference(time.period.plannedStart!).inDays;

  res +=
      ' -> ${dateToString(time.period.plannedEnd!, endDaysDiff, !time.period.toOrder)}';

  return res;
}

void stringToTime(Task task) {
  String input = task.title;
  Time time = task.time;
  List<String> partsToDelete = [];
  // modifies everything

  // 12 jan 12:00 -> 13:00
  if (input.contains(' -> ')) {
    List<String> parts = input.split(' -> ');
    partsToDelete.add(' -> ');
    stringToDateTime(time, parts[0], partsToDelete);
    Time end = Time.copy(time);
    stringToDateTime(end, parts[1], partsToDelete);
    time.period.plannedEnd = end.period.plannedStart;
  } else if (input.contains(' for ')) {
    // 21 jan 12:00 for 1m/h/d/w/M/y
    partsToDelete.add(' for ');
    List<String> parts = input.split(' for ');
    stringToDateTime(time, parts[0], partsToDelete);
    stringToHoursMins(time, parts[0], partsToDelete);

    Match? match = RegExp(r'\b(\d+)([mhdywMy])\b').firstMatch(parts[1]);
    if (match != null) {
      partsToDelete.add(match.group(0)!);
      int number = int.parse(match.group(1)!);
      String unit = match.group(2)!;
      switch (unit) {
        case 'm':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(minutes: number));
          break;
        case 'h':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(hours: number));
          break;
        case 'd':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(days: number));
          break;
        case 'w':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(days: number * 7));
          break;
        case 'M':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(days: number * 31));
          break;
        case 'y':
          time.period.plannedEnd =
              time.period.plannedStart!.add(Duration(days: number * 365));
          break;
      }
    }
  } else {
    // 12 jan 12:00
    stringToDateTime(time, input, partsToDelete);
  }

  for (var part in partsToDelete) {
    task.title = task.title.replaceAll(part, '');
  }
  task.title = task.title.replaceAll(RegExp(r'\s+'), ' ');
  task.title = task.title.trim();
}

void stringToDateTime(Time time, String input, List<String> partsToDelete) {
  // modifies startDateTime, reccurenceGap, toOrder

  // in 5m/h
  Match? match = RegExp(r'\bin (\d+)([mh])\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int number = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    switch (unit) {
      case 'm':
        time.period.plannedStart = DateTime(
            now.year, now.month, now.day, now.hour, now.minute + number);
        break;
      case 'h':
        time.period.plannedStart = DateTime(
            now.year, now.month, now.day, now.hour + number, now.minute);
        break;
    }

    time.period.toOrder = false;
    time.reccurenceGap = null;

    return;
  }

  stringToDate(time, input, partsToDelete);

  stringToHoursMins(time, input, partsToDelete);
}

void stringToHoursMins(Time time, String input, List<String> partsToDelete) {
  // only modifies startDateTime

  // no time
  if (input.contains('no time')) {
    time.period.toOrder = true;
    partsToDelete.add('no time');
    if (time.period.plannedStart != null) {
      time.period.plannedStart = DateTime(time.period.plannedStart!.year,
          time.period.plannedStart!.month, time.period.plannedStart!.day);
    }
    return;
  }

  // 12:34
  Match? match = RegExp(r"\b(\d{1,2}):(\d{2})\b").firstMatch(input);
  if (match != null && match.group(0) != null) {
    time.period.toOrder = false;
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(':');
    time.period.plannedStart ??= DateTime(now.year, now.month, now.day);
    time.period.plannedStart = DateTime(
        time.period.plannedStart!.year,
        time.period.plannedStart!.month,
        time.period.plannedStart!.day,
        int.parse(parts[0]),
        int.parse(parts[1]));
    return;
  }
}

void stringToDate(Time time, String input, List<String> partsToDelete) {
  // only modifies startDateTime, reccuranceGap
  Match? match;

  // no date
  if (input.contains('no date')) {
    partsToDelete.add('no date');
    time.period.plannedStart = null;
    time.reccurenceGap = null;
    return;
  }

  // tod/tom
  if (input.contains('tod')) {
    partsToDelete.add('tod');
    time.period.plannedStart = DateTime(now.year, now.month, now.day);
    time.reccurenceGap = null;
    return;
  }
  if (input.contains('tom')) {
    partsToDelete.add('tom');
    time.period.plannedStart = DateTime(now.year, now.month, now.day + 1);
    time.reccurenceGap = null;
    return;
  }

  // 12.1.2024
  match = RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])\.\d{4}\b")
      .firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split('.');
    time.period.plannedStart =
        DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12 jan 2024
  match = RegExp(
    r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s\d{4}\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(' ');
    time.period.plannedStart = DateTime(int.parse(parts[2]),
        monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12.1
  match =
      RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])").firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split('.');
    time.period.plannedStart =
        DateTime(now.year, int.parse(parts[1]), int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // 12 jan
  match = RegExp(
    r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(' ');
    time.period.plannedStart = DateTime(
        now.year, monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    time.reccurenceGap = null;
    return;
  }

  // this 12
  match = RegExp(
    r"\bthis\s(3[01]|[12][0-9]|[1-9])\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(' ');
    time.period.plannedStart =
        DateTime(now.year, now.month, int.parse(parts[1]));
    time.reccurenceGap = null;
    return;
  }

  // every 12
  match = RegExp(
    r"\bevery\s(3[01]|[12][0-9]|[1-9])\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(' ');
    time.period.plannedStart =
        DateTime(now.year, now.month, int.parse(parts[1]));
    time.reccurenceGap = const Duration(days: 31);
    return;
  }

  // every mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"\bevery\s(mon|tue|wed|thu|fri|sat|sun)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int day = weekDayMap[match.group(1)!]!;
    int daysDiff = day - now.weekday;
    if (daysDiff < 0) daysDiff += 7;
    final nextWekkDay = now.add(Duration(days: daysDiff));
    time.period.plannedStart =
        DateTime(nextWekkDay.year, nextWekkDay.month, nextWekkDay.day);
    time.reccurenceGap = const Duration(days: 7);
    return;
  }

  // mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"\b(mon|tue|wed|thu|fri|sat|sun)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int day = weekDayMap[match.group(0)!]!;
    int daysDiff = day - now.weekday;
    if (daysDiff < 0) daysDiff += 7;
    final nextWeekDay = now.add(Duration(days: daysDiff));
    time.period.plannedStart =
        DateTime(nextWeekDay.year, nextWeekDay.month, nextWeekDay.day);
    time.reccurenceGap = null;
    return;
  }

  // in 5d/w/M/y
  match = RegExp(r'\bin (\d+)([dwMy])\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int number = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    switch (unit) {
      case 'd':
        time.period.plannedStart =
            DateTime(now.year, now.month, now.day + number);
        break;
      case 'w':
        time.period.plannedStart =
            DateTime(now.year, now.month, now.day + number * 7);
        break;
      case 'M':
        time.period.plannedStart =
            DateTime(now.year, now.month + number, now.day);
        break;
      case 'y':
        time.period.plannedStart =
            DateTime(now.year + number, now.month, now.day);
        break;
    }

    time.period.toOrder = true;
    time.reccurenceGap = null;

    return;
  }

  return;
}

int substractDays(DateTime d1, DateTime d2) {
  DateTime truncD1 = DateTime(d1.year, d1.month, d1.day);
  DateTime truncD2 = DateTime(d2.year, d2.month, d2.day);
  return truncD1.difference(truncD2).inDays;
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
