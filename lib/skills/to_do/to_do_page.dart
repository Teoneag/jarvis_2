import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
      var newTasks = await Firestore.getTasks();
      newTasks.sort((a, b) => a.compareTo(b));
      final newTasksMap = {for (var task in newTasks) task.id: task};

      // 1. Delete tasks that are not in the new list
      for (int i = 0; i < _tasks.length; i++) {
        if (!newTasksMap.containsKey(_tasks[i].id)) {
          setState(() => _tasks.removeAt(i));
          i--;
        }
      }

      // 2. Update tasks that are in the new list
      for (int i = 0; i < _tasks.length; i++) {
        Task newTask = newTasksMap[_tasks[i].id]!;
        if (_tasks[i] != newTask) {
          setState(() => _tasks[i] = newTask);
        }
      }

      // 3. Add new tasks while keeping the order
      for (int i = 0; i < newTasks.length; i++) {
        Task newTask = newTasks[i];
        if (!_tasks.contains(newTask)) {
          int index = _tasks.indexWhere((task) => task.compareTo(newTask) > 0);
          if (index == -1) index = _tasks.length;
          setState(() => _tasks.insert(index, newTask));
        }
      }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    const Text('Order by '),
                    const Text('date'), // TODO
                    const Spacer(),
                    IconButton(
                      onPressed: _isSyncing ? null : _syncTasks,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.sync),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TaskList(
                  _tasks,
                  _addTaskNotifier,
                ),
              ),
            ],
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
