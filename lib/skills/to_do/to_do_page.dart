import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../global/global_variables.dart';
import '../../global/page_abstract.dart';
import 'dialogs/add_edit_task_dialog.dart';
import './models/task_model.dart';
import './firestore/firestore_methods.dart';
import 'widgets/task_list.dart';

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
  List<Task> _tasks = [];

  Future<void> _syncTasks() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      _tasks = await Firestore.getTasks();
      _tasks.sort((a, b) => a.compareTo(b));
      for (var task in _tasks) {
        await Task.loadSubTasks(task);
      }
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

  void _deleteTask(int index) async {
    try {
      final id = _tasks[index].id;
      setState(() => _tasks.removeAt(index));
      await Firestore.deleteTask(id);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Error deleting task: $e'),
      ));
    }
  }

  void _completeTask(int index) async {
    try {
      final task = _tasks[index];
      setState(() => _tasks.removeAt(index));
      await Firestore.updateTask(task);
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
      body: TaskList(
        _tasks,
        _deleteTask,
        _completeTask,
        _showAddEditTaskDialog,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTaskDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
