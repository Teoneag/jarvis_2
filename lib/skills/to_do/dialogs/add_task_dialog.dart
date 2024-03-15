import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../firestore/firestore_methods.dart';
import '../models/task_model.dart';
import '../enums/priority_enum.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({Key? key}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  Priority _selectedPriority = Priority.none;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Task newTask = Task.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );
      FirestoreMethods.addTask(newTask).then((taskId) {
        if (taskId.isNotEmpty) {
          Navigator.of(context).pop();
          _titleController.clear();
          _descriptionController.clear();
        }
      });
    } else {
      _titleFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
                onFieldSubmitted: (_) => _submitForm(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                decoration: const InputDecoration(hintText: 'Description'),
                onFieldSubmitted: (_) => _submitForm(),
              ),
              Focus(
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _submitForm();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: DropdownButton<Priority>(
                  isExpanded: true,
                  value: _selectedPriority,
                  items: Priority.values
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (Priority? newValue) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _selectedPriority = newValue ?? Priority.none;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
