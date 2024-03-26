import 'package:flutter/material.dart';

import '../../global/global_variables.dart';
import '../../global/page_abstract.dart';
import './models/task_model.dart';
import './firestore/firestore_methods.dart';
import 'widgets/task_list_and_add.dart';

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
  bool _isSyncing = false;
  final List<Task> _tasks = [];

  Future<void> _syncTasks() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      _tasks.clear();
      _tasks.addAll(await Firestore.getTasks());
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

  @override
  void initState() {
    _syncTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TaskListAndAdd(_tasks);
  }
}
