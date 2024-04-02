import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jarvis_2/skills/to_do/firestore/firestore_methods.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';

import '../enums/priority_enum.dart';
import '../models/task_model.dart';

const String todoistApiToken = '75080e7a87399c767c24335610c0271ab0caf46a';
const String todoistApiUrl = 'https://api.todoist.com/rest/v2/tasks';

Future<List<dynamic>> fetchTodoistTasks() async {
  print('Starting to fetch tasks...');
  final response = await http.get(
    Uri.parse(todoistApiUrl),
    headers: {'Authorization': 'Bearer $todoistApiToken'},
  );

  if (response.statusCode == 200) {
    print('Successfully fetched tasks.');
    // print('Response: ${response.body}');
    return json.decode(response.body);
  } else {
    print('Failed to fetch tasks. Status code: ${response.statusCode}');
    return [];
  }
}

Future<void> printFirst10Tasks() async {
  print('Adding buy later task.');
  Task buyLaterTask = Task(title: 'Buy later'); // TODO pin this task
  final buyId = await Firestore.addTask(buyLaterTask);
  print('Added buy later task.');

  final tasks = await fetchTodoistTasks();
  for (var i = 0; i < tasks.length; i++) {
    Task task = Task();
    task.title = tasks[i]['content'];
    if (tasks[i]['project_id'] == '2294247462') task.labels.add('bDay');
    const toBuyId = '2294257831';
    if (tasks[i]['project_id'] == toBuyId) {
      task.parentTaskId = buyId;
    }
    // TODO find a better way to handle labels
    task.id = tasks[i]['id'].toString();
    task.description = tasks[i]['description'];
    task.isDone = tasks[i]['is_completed'];
    task.labels.addAll(List<String>.from(tasks[i]['labels']));
    task.parentTaskId ??= tasks[i]['parent_id'];
    switch (tasks[i]['priority']) {
      case 4:
        task.priority = Priority.p0;
        break;
      case 3:
        task.priority = Priority.p1;
        break;
      default:
        task.priority = Priority.none;
    }

    if (tasks[i]['due'] != null) {
      task.period.plannedStart = DateTime.parse(tasks[i]['due']['date']);
      if (tasks[i]['due']['is_recurring'] == true) {
        final dateString = tasks[i]['due']['string'];
        if (dateString == 'every year') {
          task.time.reccurenceGap = const Duration(days: 365);
        } else {
          taskToTime(dateString, task.time, []);
        }
      }
    }
    print(task);
    await Firestore.addTaskWithId(task);
    if (tasks[i]['project_id'] == toBuyId) {
      await Firestore.addSubTask(buyId, task.id);
    }
  }
}
