import 'package:flutter/material.dart';

import 'package:jarvis_2/skills/to_do/enums/priority_enum.dart';
import '../methods/time_methods.dart';
import '../models/task_model.dart';

class TaskListTile extends StatefulWidget {
  final Task task;
  final Function deleteTask;
  final Function completeTask;
  const TaskListTile(this.task, this.deleteTask, this.completeTask,
      {super.key});

  @override
  State<TaskListTile> createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        title: Text(widget.task.title),
        subtitle: timeToShortWidget(widget.task.time),
        leading: widget.task.isRunning
            ? IconButton(
                icon: Icon(
                  Icons.stop_outlined,
                  color: widget.task.priority.color,
                ),
                onPressed: () => setState(() {
                  widget.task.stop();
                  widget.completeTask();
                }),
              )
            : IconButton(
                icon: Icon(
                  Icons.play_arrow_outlined,
                  color: widget.task.priority.color,
                ),
                onPressed: () => setState(() => widget.task.start()),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => widget.deleteTask(),
        ),
      ),
    );
  }
}
