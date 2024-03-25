import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'task_list_tile.dart';

class TaskList extends StatelessWidget {
  final List<Task> _tasks;
  String 

  const TaskList(
    this._tasks,
    this.deleteTask,
    this.completeTask,
    this.showAddEditTaskDialog, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final task = _tasks[index];
        return InkWell(
          onTap: () => showAddEditTaskDialog(index),
          child: TaskListTile(
            task,
            () => deleteTask(index),
            () => completeTask(index),
          ),
        );
      },
    );
  }
}
