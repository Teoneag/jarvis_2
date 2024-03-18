class TimeField {
  static const String startDateTime = 'startDateTime';
  static const String plannedDuration = 'plannedDuration';
  static const String actualDuration = 'actualDuration';
  static const String reccuranceGap = 'reccuranceGap';
  static const String toOrder = 'toOrder';
}

class Time {
  DateTime? start;
  Duration? plannedDuration;
  Duration? actualDuration;
  Duration? reccurenceGap;
  bool toOrder; // if it has no start time, only start date

  Time({
    this.start,
    this.plannedDuration,
    this.actualDuration,
    this.reccurenceGap,
    this.toOrder = true,
  });

  factory Time.fromFirestore(Map<String, dynamic> data) {
    return Time(
      start: data[TimeField.startDateTime]?.toDate(),
      plannedDuration: data[TimeField.plannedDuration] != null
          ? Duration(seconds: data[TimeField.plannedDuration])
          : null,
      actualDuration: data[TimeField.actualDuration] != null
          ? Duration(seconds: data[TimeField.actualDuration])
          : null,
      reccurenceGap: data[TimeField.reccuranceGap] != null
          ? Duration(seconds: data[TimeField.reccuranceGap])
          : null,
      toOrder: data[TimeField.toOrder],
    );
  }

  Time.copy(Time time)
      : start = time.start,
        plannedDuration = time.plannedDuration,
        actualDuration = time.actualDuration,
        reccurenceGap = time.reccurenceGap,
        toOrder = time.toOrder;

  Map<String, dynamic> toFirestore() {
    return {
      TimeField.startDateTime: start,
      TimeField.plannedDuration: plannedDuration?.inSeconds,
      TimeField.actualDuration: actualDuration?.inSeconds,
      TimeField.reccuranceGap: reccurenceGap?.inSeconds,
      TimeField.toOrder: toOrder,
    };
  }
}
