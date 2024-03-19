class TimeField {
  static const String plannedStart = 'plannedStart';
  static const String actualStart = 'actualStart';
  static const String plannedEnd = 'plannedEnd';
  static const String actualEnd = 'actualEnd';
  static const String reccuranceGap = 'reccuranceGap';
  static const String toOrder = 'toOrder';
}

class Time {
  DateTime? plannedStart;
  DateTime? actualStart;
  DateTime? plannedEnd;
  DateTime? actualEnd;
  Duration? reccurenceGap;
  bool toOrder; // if it has no start time, only start date

  Time({
    this.plannedStart,
    this.actualStart,
    this.plannedEnd,
    this.actualEnd,
    this.reccurenceGap,
    this.toOrder = true,
  });

  factory Time.fromFirestore(Map<String, dynamic> data) {
    return Time(
      plannedStart: data[TimeField.plannedStart]?.toDate(),
      actualStart: data[TimeField.actualStart]?.toDate(),
      plannedEnd: data[TimeField.plannedEnd]?.toDate(),
      actualEnd: data[TimeField.actualEnd]?.toDate(),
      reccurenceGap: data[TimeField.reccuranceGap] != null
          ? Duration(seconds: data[TimeField.reccuranceGap])
          : null,
      toOrder: data[TimeField.toOrder],
    );
  }

  Time.copy(Time time)
      : plannedStart = time.plannedStart,
        actualStart = time.actualStart,
        plannedEnd = time.plannedEnd,
        actualEnd = time.actualEnd,
        reccurenceGap = time.reccurenceGap,
        toOrder = time.toOrder;

  Map<String, dynamic> toFirestore() {
    return {
      TimeField.plannedStart: plannedStart,
      TimeField.actualStart: actualStart,
      TimeField.plannedEnd: plannedEnd,
      TimeField.actualEnd: actualEnd,
      TimeField.reccuranceGap: reccurenceGap?.inSeconds,
      TimeField.toOrder: toOrder,
    };
  }
}
