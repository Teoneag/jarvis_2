import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../models/time_model.dart';
import '../models/time_period_model.dart';

void completeTask(Task task) {
  if (task.time.reccurenceGap == null) {
    task.isDone = true;
    return;
  }

  DateTime plannedStart =
      task.time.period.plannedStart!.add(task.time.reccurenceGap!);

  task.time.periods.insert(0, TimePeriod(plannedStart: plannedStart));
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

  final daysDiff = _substractDays(time.period.plannedStart!, DateTime.now());

  String res = '';

  res +=
      _dateToString(time.period.plannedStart!, daysDiff, !time.period.toOrder);

  if (time.period.plannedEnd == null) return res;

  final endDaysDiff =
      time.period.plannedEnd!.difference(time.period.plannedStart!).inDays;

  res +=
      ' -> ${_dateToString(time.period.plannedEnd!, endDaysDiff, !time.period.toOrder)}';

  return res;
}

void stringToTime(Task task) {
  // modifies everything
  List<String> partsToDelete = [];
  taskToTime(task.title, task.time, partsToDelete);
  for (var part in partsToDelete) {
    task.title = task.title.replaceAll(part, '');
  }
  task.title = task.title.replaceAll(RegExp(r'\s+'), ' ');
  task.title = task.title.trim();
}

void taskToTime(String input, Time time, List<String> partsToDelete) {
  if (time.period.plannedStart == null ||
      time.period.plannedStart!.hour == 0 &&
          time.period.plannedStart!.minute == 0) {
    time.period.toOrder = true;
  }

  // 12 jan 12:00 -> 13:00
  // 12 jan 12:00->13:00
  if (input.contains('->')) {
    List<String> parts = input.split('->');
    if (input.contains(' -> ')) {
      partsToDelete.add(' -> ');
    } else {
      partsToDelete.add('->');
    }
    bool ok = _stringToDateTime(time, parts[0], partsToDelete);
    Time end = Time.copy(time);
    ok = ok & _stringToDateTime(end, parts[1], partsToDelete);
    if (ok == false) partsToDelete.removeLast();
    time.period.plannedEnd = end.period.plannedStart;
  } else if (input.contains(' for ')) {
    // 21 jan 12:00 for 1m/h/d/w/M/y
    partsToDelete.add(' for ');
    List<String> parts = input.split(' for ');
    _stringToDateTime(time, parts[0], partsToDelete);
    _stringToHoursMins(time, parts[0], partsToDelete);

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
    _stringToDateTime(time, input, partsToDelete);
  }
}

String _dateToString(DateTime date, int daysDiff, bool includeTime) {
  if (daysDiff < 0) {
    return 'Passed: ${DateFormat(includeTime ? 'd MMM yyyy HH:mm' : 'd MMM yyyy').format(date)}';
  }
  if (daysDiff == 0) {
    return includeTime ? DateFormat('HH:mm').format(date) : 'tod';
  } else if (daysDiff == 1) {
    return includeTime ? 'tom ${DateFormat('HH:mm').format(date)}' : 'tom';
  } else if (daysDiff <= 7) {
    return DateFormat(includeTime ? 'EEE HH:mm' : 'EEE').format(date);
  } else if (date.year > _now.year) {
    return DateFormat(includeTime ? 'd MMM HH:mm' : 'd MMM').format(date);
  } else {
    return DateFormat(includeTime ? 'd MMM yyyy HH:mm' : 'd MMM yyyy')
        .format(date);
  }
}

// returns true if the input contains a time
bool _stringToDateTime(Time time, String input, List<String> partsToDelete) {
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
            _now.year, _now.month, _now.day, _now.hour, _now.minute + number);
        break;
      case 'h':
        time.period.plannedStart = DateTime(
            _now.year, _now.month, _now.day, _now.hour + number, _now.minute);
        break;
    }

    time.period.toOrder = false;
    time.reccurenceGap = null;

    return true;
  }

  bool res = _stringToDate(time, input, partsToDelete);

  res = res | _stringToHoursMins(time, input, partsToDelete);

  return res;
}

bool _stringToHoursMins(Time time, String input, List<String> partsToDelete) {
  // only modifies startDateTime

  // no time
  if (input.contains('no time')) {
    time.period.toOrder = true;
    partsToDelete.add('no time');
    if (time.period.plannedStart != null) {
      time.period.plannedStart = DateTime(time.period.plannedStart!.year,
          time.period.plannedStart!.month, time.period.plannedStart!.day);
    }
    return true;
  }

  // 12:34
  Match? match = RegExp(r"\b(\d{1,2}):(\d{2})\b").firstMatch(input);
  if (match != null && match.group(0) != null) {
    time.period.toOrder = false;
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split(':');
    time.period.plannedStart ??= DateTime(_now.year, _now.month, _now.day);
    time.period.plannedStart = DateTime(
        time.period.plannedStart!.year,
        time.period.plannedStart!.month,
        time.period.plannedStart!.day,
        int.parse(parts[0]),
        int.parse(parts[1]));
    return true;
  }

  return false;
}

bool _stringToDate(Time time, String input, List<String> partsToDelete) {
  // only modifies startDateTime, reccuranceGap
  Match? match;

  // no date
  match = RegExp(r'\bno date\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add('no date');
    time.period.plannedStart = null;
    time.period.plannedEnd = null;
    time.reccurenceGap = null;
    return true;
  }

  // tod
  match = RegExp(r"\btod\b").firstMatch(input);
  if (match != null) {
    partsToDelete.add('tod');
    time.period.plannedStart = DateTime(_now.year, _now.month, _now.day);
    time.reccurenceGap = null;
    return true;
  }

  // tom
  match = RegExp(r"\btom\b").firstMatch(input);
  if (match != null) {
    partsToDelete.add('tom');
    time.period.plannedStart = DateTime(_now.year, _now.month, _now.day + 1);
    time.reccurenceGap = null;
    return true;
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
    return true;
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
        _monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    time.reccurenceGap = null;
    return true;
  }

  // 12.1
  match = RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9]|0[1-9])")
      .firstMatch(input);
  if (match != null && match.group(0) != null) {
    partsToDelete.add(match.group(0)!);
    List<String> parts = match.group(0)!.split('.');
    time.period.plannedStart =
        DateTime(_now.year, int.parse(parts[1]), int.parse(parts[0]));
    time.reccurenceGap = null;
    return true;
  }

  // every 2 jan
  match = RegExp(
          r'\bevery (\d+) (jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)\b',
          caseSensitive: false)
      .firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int number = int.parse(match.group(1)!);
    String month = match.group(2)!;
    time.period.plannedStart = DateTime(_now.year, _monthMap[month]!, number);
    time.reccurenceGap = const Duration(days: 365);
    return true;
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
        _now.year, _monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    // if the date is in the past, it is assumed to be next year
    if (time.period.plannedStart!.isBefore(_now)) {
      time.period.plannedStart = DateTime(_now.year + 1,
          _monthMap[parts[1].toLowerCase()]!, int.parse(parts[0]));
    }
    time.reccurenceGap = null;
    return true;
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
        DateTime(_now.year, _now.month, int.parse(parts[1]));
    time.reccurenceGap = null;
    return true;
  }

  // every 5d/w/M/y/days/weeks/months/years
  match = RegExp(
          r'\bevery (\d+)\s*(d|day|days|w|week|weeks|M|month|months|y|year|years)\b')
      .firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int number = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    time.period.plannedStart = DateTime(_now.year, _now.month, _now.day);
    switch (unit) {
      case 'd':
      case 'day':
      case 'days':
        time.reccurenceGap = Duration(days: 1 * number);
        break;
      case 'w':
      case 'week':
      case 'weeks':
        time.reccurenceGap = Duration(days: 7 * number);
        break;
      case 'M':
      case 'month':
      case 'months':
        time.reccurenceGap = Duration(days: 31 * number);
        break;
      case 'y':
      case 'year':
      case 'years':
        time.reccurenceGap = Duration(days: 365 * number);
        break;
    }

    return true;
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
        DateTime(_now.year, _now.month, int.parse(parts[1]));
    time.reccurenceGap = const Duration(days: 31);
    return true;
  }

  // every mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"\bevery\s(mon|tue|wed|thu|fri|sat|sun)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int day = _weekDayMap[match.group(1)!.toLowerCase()]!;
    int daysDiff = day - _now.weekday;
    if (daysDiff < 0) daysDiff += 7;
    final nextWekkDay = _now.add(Duration(days: daysDiff));
    time.period.plannedStart =
        DateTime(nextWekkDay.year, nextWekkDay.month, nextWekkDay.day);
    time.reccurenceGap = const Duration(days: 7);
    return true;
  }

  // every last mon/tue/wed/thu/fri/sat/sun
  // TODO store the data that is the last day of the month
  match = RegExp(
    r"\bevery last (mon|tue|wed|thu|fri|sat|sun)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int day = _weekDayMap[match.group(1)!]!;
    int daysDiff = day - _now.weekday;
    if (daysDiff < 0) daysDiff += 7;
    final nextWeekDay = _now.add(Duration(days: daysDiff));
    time.period.plannedStart =
        DateTime(nextWeekDay.year, nextWeekDay.month, nextWeekDay.day);
    time.reccurenceGap = const Duration(days: 7);
    return true;
  }

  // mon/tue/wed/thu/fri/sat/sun
  match = RegExp(
    r"\b(mon|tue|wed|thu|fri|sat|sun)\b",
    caseSensitive: false,
  ).firstMatch(input);
  if (match != null) {
    partsToDelete.add(match.group(0)!);
    int day = _weekDayMap[match.group(0)!]!;
    int daysDiff = day - _now.weekday;
    if (daysDiff < 0) daysDiff += 7;
    final nextWeekDay = _now.add(Duration(days: daysDiff));
    time.period.plannedStart =
        DateTime(nextWeekDay.year, nextWeekDay.month, nextWeekDay.day);
    time.reccurenceGap = null;
    return true;
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
            DateTime(_now.year, _now.month, _now.day + number);
        break;
      case 'w':
        time.period.plannedStart =
            DateTime(_now.year, _now.month, _now.day + number * 7);
        break;
      case 'M':
        time.period.plannedStart =
            DateTime(_now.year, _now.month + number, _now.day);
        break;
      case 'y':
        time.period.plannedStart =
            DateTime(_now.year + number, _now.month, _now.day);
        break;
    }

    time.reccurenceGap = null;

    return true;
  }

  // daily
  match = RegExp(r'\bdaily\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add('daily');
    time.period.plannedStart = DateTime(_now.year, _now.month, _now.day);
    time.reccurenceGap = const Duration(days: 1);
    return true;
  }

  // every day
  match = RegExp(r'\bevery day\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add('every day');
    time.period.plannedStart = DateTime(_now.year, _now.month, _now.day);
    time.reccurenceGap = const Duration(days: 1);
    return true;
  }

  // every last day
  // TODO store the data that is the last day of the month
  match = RegExp(r'\bevery last day\b').firstMatch(input);
  if (match != null) {
    partsToDelete.add('every last day');
    time.period.plannedStart = DateTime(_now.year, _now.month + 1, 0);
    time.reccurenceGap = const Duration(days: 31);
    return true;
  }

  return false;
}

int _substractDays(DateTime d1, DateTime d2) {
  // time is converted to utc to avoid timezone issues and DST
  DateTime truncD1 = DateTime.utc(d1.year, d1.month, d1.day);
  DateTime truncD2 = DateTime.utc(d2.year, d2.month, d2.day);
  return truncD1.difference(truncD2).inDays;
}

DateTime min(DateTime d1, DateTime? d2) {
  if (d2 == null) return d1;
  return d1.isBefore(d2) ? d1 : d2;
}

final _now = DateTime.now();

const _monthMap = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'sept': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

const _weekDayMap = {
  'mon': 1,
  'tue': 2,
  'wed': 3,
  'thu': 4,
  'fri': 5,
  'sat': 6,
  'sun': 7,
};
