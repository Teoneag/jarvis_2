import '/skills/to_do/models/time_period_model.dart';

class TimeField {
  static const String reccuranceGap = 'reccuranceGap';
  static const String periods = 'periods';
}

class Time implements Comparable<Time> {
  List<TimePeriod> periods = []; // 1st period is the current one
  Duration? reccurenceGap;

  Time({
    periods,
    this.reccurenceGap,
  }) : periods = periods ?? [TimePeriod()];

  factory Time.fromFirestore(Map<String, dynamic> data) {
    final list = data[TimeField.periods] as List;
    final gap = data[TimeField.reccuranceGap];
    return Time(
      periods: list.map((period) => TimePeriod.fromFirestore(period)).toList(),
      reccurenceGap: gap != null ? Duration(seconds: gap) : null,
    );
  }

  TimePeriod get period => periods[0];

  bool get isRunning => period.actualStart != null;

  Time.copy(Time time)
      : reccurenceGap = time.reccurenceGap,
        periods =
            time.periods.map((period) => TimePeriod.copy(period)).toList();

  Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>> periodsToFirestore =
        periods.map((period) => period.toFirestore()).toList();

    return {
      TimeField.periods: periodsToFirestore,
      TimeField.reccuranceGap: reccurenceGap?.inSeconds,
    };
  }

  @override
  int compareTo(Time other) {
    if (period.plannedStart == null) return 1;
    if (other.period.plannedStart == null) return -1;

    final aTime = period.plannedStart!;
    final bTime = other.period.plannedStart!;
    if (aTime.day == bTime.day &&
        aTime.month == bTime.month &&
        aTime.year == bTime.year) {
      if (period.toOrder == true) return 1;
      if (other.period.toOrder == true) return -1;
    }

    return period.plannedStart!.compareTo(other.period.plannedStart!);
  }

  @override
  String toString() {
    return 'Time{periods: $periods, reccurenceGap: $reccurenceGap}';
  }
}
