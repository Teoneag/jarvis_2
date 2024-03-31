import 'package:flutter/material.dart';

import '../dialogs/add_edit_task_dialog.dart';
import '../firestore/firestore_methods.dart';
import '../models/task_model.dart';
import 'task_list_tile.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final ChangeNotifier onCreateTaskChange;
  final String? parentTaskId;
  final void Function()? onDialogClose;

  const TaskList(
    this.tasks,
    this.onCreateTaskChange, {
    this.parentTaskId,
    this.onDialogClose,
    super.key,
  });
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
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
            if (widget.parentTaskId != null) {
              await Firestore.addSubTask(widget.parentTaskId!, id);
            }
            newTask.id = id;
            int index = _tasks.indexWhere((task) => task.id == newTask.id);
            if (index == -1) index = _tasks.length;
            setState(() => _tasks.insert(index, newTask));
            Navigator.of(context).pop();
          },
        ),
      ).then((value) => widget.onDialogClose?.call());
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
            Navigator.of(context).pop();
          },
        ),
      ).then((value) => widget.onDialogClose?.call());
    });
  }

  Future<void> _deleteTask(int index) async {
    final id = _tasks[index].id;
    setState(() => _tasks.removeAt(index));
    if (widget.parentTaskId != null) {
      await Firestore.deleteSubTask(widget.parentTaskId!, id);
      return;
    }
    await Firestore.deleteTask(id);
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    if (task.period.plannedEnd != null) {
      _tasks.removeAt(index);
      await Firestore.deleteSubTask(widget.parentTaskId!, task.id);
    }
    setState(() {});
    // TODO if parentTaskId is not null, show it crossed out
    await Firestore.updateTask(task);
  }

  @override
  void initState() {
    _tasks = widget.tasks;
    widget.onCreateTaskChange.addListener(_createTask);
    super.initState();
  }

  @override
  void dispose() {
    widget.onCreateTaskChange.removeListener(_createTask);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return ReorderableDelayedDragStartListener(
          index: index,
          key: ValueKey(_tasks[index].id),
          child: InkWell(
            onTap: () => _editTask(index),
            child: TaskListTile(
              _tasks[index],
              () => _deleteTask(index),
              () => _completeTask(index),
            ),
          ),
        );
      },
      onReorder: (int oldIndex, int newIndex) async {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final Task item = _tasks.removeAt(oldIndex);
          _tasks.insert(newIndex, item);
        });
        if (widget.parentTaskId != null) {
          await Firestore.reorderSubTask(
              widget.parentTaskId!, _tasks.map((e) => e.id).toList());
        }
      },
    );
  }
}
