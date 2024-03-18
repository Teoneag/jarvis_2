import 'package:flutter/material.dart';
import 'package:jarvis_2/skills/to_do/enums/priority_enum.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';
import 'package:jarvis_2/skills/to_do/models/task_model.dart';

Widget taskListTile(Task task, Function deleteTask) => ListTile(
      title: Text(task.title),
      subtitle: dateToShortWidget(task.time),
      leading: IconButton(
        icon: Icon(
          Icons.circle_outlined,
          color: task.priority.color,
        ),
        onPressed: () {},
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => deleteTask(task.id),
      ),
    );
