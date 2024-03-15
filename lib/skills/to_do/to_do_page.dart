import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/abstracts/page.dart';
import './dialogs/add_task_dialog.dart';
import './models/task_model.dart';
import './enums/priority_enum.dart';
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

  void _showAddTaskDialog() {
    if (_isDialogOpen) {
      return;
    }
    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTaskDialog();
      },
    ).then((_) => setState(() => _isDialogOpen = false));
  }

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyPress);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Task>>(
        future: FirestoreMethods.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  leading: Icon(task.priority == Priority.p0
                      ? Icons.error_outline
                      : task.priority == Priority.p1
                          ? Icons.warning_amber_outlined
                          : Icons.check_circle_outline),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
