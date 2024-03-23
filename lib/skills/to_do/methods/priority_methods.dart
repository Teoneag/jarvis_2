import '../enums/priority_enum.dart';
import '../models/task_model.dart';

class PriorityMethods {
  static void stringToPriority(Task task) {
    if (task.title.contains('p0')) {
      task.priority = Priority.p0;
      task.title = task.title.replaceAll('p0', '');
    } else if (task.title.contains('p1')) {
      task.priority = Priority.p1;
      task.title = task.title.replaceAll('p1', '');
    } else if (task.title.contains('pnone')) {
      task.priority = Priority.none;
      task.title = task.title.replaceAll('pnone', '');
    }
  }
}
