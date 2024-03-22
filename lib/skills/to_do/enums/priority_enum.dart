import 'package:flutter/material.dart';

enum Priority {
  p0,
  p1,
  none,
}

extension PriorityColorExtension on Priority {
  Color get color {
    switch (this) {
      case Priority.p0:
        return Colors.red;
      case Priority.p1:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

extension PriorityStringExtension on Priority {
  String get string {
    switch (this) {
      case Priority.p0:
        return 'p0';
      case Priority.p1:
        return 'p1';
      default:
        return 'no priority';
    }
  }
}
