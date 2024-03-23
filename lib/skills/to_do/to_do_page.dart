import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../global/global_variables.dart';
import '/skills/to_do/widgets/task_list_tile.dart';
import '../../global/page_abstract.dart';
import 'dialogs/add_edit_task_dialog.dart';
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
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Error syncing tasks: $e'),
      ));
    }
    setState(() => _isSyncing = false);
  }

  void _showAddEditTaskDialog(int? index) {
    if (_isDialogOpen) return;

    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditTaskDialog(
          _tasks,
          index: index,
        );
      },
    ).then((_) => setState(() => _isDialogOpen = false));
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        _showAddEditTaskDialog(null);
        return true;
      }
    }
    return false;
  }

  void _deleteTask(String taskId) async {
    try {
      setState(() => _tasks.remove(taskId));
      await Firestore.deleteTask(taskId);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Error deleting task: $e'),
      ));
    }
  }

  void _completeTask(String taskId) async {
    try {
      setState(() => _tasks.remove(taskId));
      await Firestore.updateTask(_tasks[taskId]!);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Error completing task: $e'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
    _syncTasks();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = _tasks.values.elementAt(index);
          return InkWell(
            onTap: () => _showAddEditTaskDialog(index),
            child: TaskListTile(task, _deleteTask, _completeTask),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTaskDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
