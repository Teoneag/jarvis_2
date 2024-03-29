class TimePeriodField {
  static const String plannedStart = 'plannedStart';
  static const String actualStart = 'actualStart';
  static const String plannedEnd = 'plannedEnd';
  static const String actualEnd = 'actualEnd';
  static const String toOrder = 'toOrder';
}

class TimePeriod {
  DateTime? plannedStart;
  DateTime? actualStart;
  DateTime? plannedEnd;
  DateTime? actualEnd;
  bool toOrder; // if it has no start time, only start date

  TimePeriod({
    this.plannedStart,
    this.actualStart,
    this.plannedEnd,
    this.actualEnd,
    this.toOrder = true,
  });

  factory TimePeriod.fromFirestore(Map<String, dynamic> data) {
    return TimePeriod(
      plannedStart: data[TimePeriodField.plannedStart]?.toDate(),
      actualStart: data[TimePeriodField.actualStart]?.toDate(),
      plannedEnd: data[TimePeriodField.plannedEnd]?.toDate(),
      actualEnd: data[TimePeriodField.actualEnd]?.toDate(),
      toOrder: data[TimePeriodField.toOrder],
    );
  }

  TimePeriod.copy(TimePeriod time)
      : plannedStart = time.plannedStart,
        actualStart = time.actualStart,
        plannedEnd = time.plannedEnd,
        actualEnd = time.actualEnd,
        toOrder = time.toOrder;

  void setStartDate(DateTime? date) {
    if (date == null) return;

    plannedStart = DateTime(
      date.year,
      date.month,
      date.day,
      plannedStart?.hour ?? 0,
      plannedStart?.minute ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      TimePeriodField.plannedStart: plannedStart,
      TimePeriodField.actualStart: actualStart,
      TimePeriodField.plannedEnd: plannedEnd,
      TimePeriodField.actualEnd: actualEnd,
      TimePeriodField.toOrder: toOrder,
    };
  }
}
