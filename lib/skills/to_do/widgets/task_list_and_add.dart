import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialogs/add_edit_task_dialog.dart';
import '../firestore/firestore_methods.dart';
import '../models/task_model.dart';
import 'task_list.dart';

class TaskListAndAdd extends StatefulWidget {
  final List<Task> tasks;
  final String? parentTaskId;
  const TaskListAndAdd(this.tasks, {this.parentTaskId, super.key});

  @override
  State<TaskListAndAdd> createState() => _TaskListAndAddState();
}

class _TaskListAndAddState extends State<TaskListAndAdd> {
  late final List<Task> _tasks;
  bool _isDialogOpen = false;

  Future<void> openDialog(Future<void> Function() action) async {
    if (_isDialogOpen) return;

    setState(() => _isDialogOpen = true);
    await action();
    setState(() => _isDialogOpen = false);
  }

  Future<void> _createTask() async {
    openDialog(() async {
      Task newTask = Task(parentTaskId: widget.parentTaskId);
      await showDialog(
        context: context,
        builder: (context) => EditTaskDialog(
          newTask,
          () async {
            final id = await Firestore.addTask(newTask);
            newTask.id = id;
            setState(() => _tasks.add(newTask));
            Navigator.of(context).pop();
            // TODO ordering
          },
        ),
      );
    });
  }

  Future<void> _editTask(int index) async {
    Task task = _tasks[index];
    openDialog(() async {
      await showDialog(
        context: context,
        builder: (context) => EditTaskDialog(
          task,
          () async {
            await Firestore.updateTask(task);
            setState(() => _tasks[index] = task);
          },
        ),
      );
    });
  }

  Future<void> _deleteTask(int index) async {
    final id = _tasks[index].id;
    setState(() => _tasks.removeAt(index));
    await Firestore.deleteTask(id);
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    setState(() => _tasks.removeAt(index));
    // TODO if parentTaskId is not null, show it crossed out
    await Firestore.updateTask(task);
  }

  @override
  void initState() {
    _tasks = widget.tasks;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ):
              const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) => _createTask(),
              // TODO see if it works nested
            ),
          },
          child: Focus(
            child: TaskList(
              _tasks,
              _deleteTask,
              _completeTask,
              _editTask,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
