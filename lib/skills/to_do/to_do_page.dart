import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/skills/to_do/widgets/task_list_tile.dart';
import '/abstracts/page.dart';
import './dialogs/add_task_dialog.dart';
import './models/task_model.dart';
import './firestore/firestore_methods.dart';

class ToDoPage extends BasePage {
  @override
  String get title => 'ToDo';
  @override
  IconData get icon => Icons.checklist;

  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  bool _isDialogOpen = false;
  bool _isSyncing = false;
  Map<String, Task> _tasks = {};

  Future<void> _syncTasks() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      _tasks = await Firestore.getTasks();
      setState(() => _isSyncing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error syncing tasks: $e'),
      ));
      setState(() => _isSyncing = false);
    }
  }

  void _showAddTaskDialog() {
    if (_isDialogOpen) {
      return;
    }
    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(_tasks);
      },
    ).then((_) => setState(() => _isDialogOpen = false));
  }

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyPress);
    _syncTasks();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyQ) {
      _showAddTaskDialog();
    }
  }

  void _deleteTask(String taskId) async {
    _tasks.remove(taskId);
    try {
      await Firestore.deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task deleted successfully'),
      ));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting task: $e'),
      ));
    }
  }

  void _completeTask(String taskId) async {
    try {
      Task task = _tasks[taskId]!;
      _tasks.remove(taskId);
      await Firestore.updateTask(task);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task completed successfully'),
      ));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error completing task: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = _tasks.values.elementAt(index);
          return TaskListTile(task, _deleteTask, _completeTask);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
