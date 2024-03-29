import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../global/global_variables.dart';
import '../../global/page_abstract.dart';
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
  bool _isSyncing = false;
  final List<Task> _tasks = [];
  final ChangeNotifier _addTaskNotifier = ChangeNotifier();

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
    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ):
              _addTaskNotifier.notifyListeners,
        },
        child: Focus(
          autofocus: true,
          child: TaskList(
            _tasks,
            _addTaskNotifier,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskNotifier.notifyListeners,
        child: const Icon(Icons.add),
      ),
    );
  }
}
