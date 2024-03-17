import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

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
  String _startDate = '';
  String _endDate = '';
  Priority _selectedPriority = Priority.none;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Task newTask = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        // startDateTime: _startDate,
        // endDateTime: _endDate,
      );
      FirestoreMethods.addTask(newTask).then((taskId) {
        if (taskId.isNotEmpty) {
          Navigator.of(context).pop();
          _titleController.clear();
          _descriptionController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              DropdownButton<Priority>(
                isExpanded: true,
                value: _selectedPriority,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue ?? Priority.none;
                  });
                },
                items: Priority.values
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        ))
                    .toList(),
              ),
              const Row(
                children: [
                  IntrinsicWidth(
                    child: TextField(),
                  ),
                  IntrinsicWidth(
                    child: TextField(),
                  ),
                ],
              ),
              SizedBox(
                width: 500,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (newDate) {
                    // setState(() {
                    //   _selectedStartDate = newDate;
                    // });
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
