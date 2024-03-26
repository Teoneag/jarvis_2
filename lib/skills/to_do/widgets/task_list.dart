import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'task_list_tile.dart';

class TaskList extends StatelessWidget {
  final List<Task> _tasks;
  final Future<void> Function(int) deleteTask;
  final Future<void> Function(int) completeTask;
  final Future<void> Function(int) editTask;

  const TaskList(
    this._tasks,
    this.deleteTask,
    this.completeTask,
    this.editTask, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => editTask(index),
          child: TaskListTile(
            _tasks[index],
            () => deleteTask(index),
            () => completeTask(index),
          ),
        );
      },
    );
  }
}
