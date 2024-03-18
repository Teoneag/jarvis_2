import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import '../firestore/firestore_methods.dart';
import '../models/task_model.dart';
import '../enums/priority_enum.dart';

class AddTaskDialog extends StatefulWidget {
  final Map<String, Task> tasks;
  const AddTaskDialog(this.tasks, {Key? key}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _planedDurationController = TextEditingController();
  final _reccuranceGapController = TextEditingController();
  Priority _selectedPriority = Priority.none;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Task newTask = Task.fromInput(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _selectedPriority,
      );
      Firestore.addTask(newTask).then((taskId) {
        if (taskId.isNotEmpty) {
          widget.tasks.addAll({taskId: newTask});
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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              onFieldSubmitted: (_) => _submitForm(),
              autofocus: true,
              focusNode: _titleFocusNode,
              decoration: const InputDecoration(hintText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  _titleFocusNode.requestFocus();
                  return 'Title cannot be empty';
                }
                return null;
              },
            ),
            TextField(
              controller: _descriptionController,
              onSubmitted: (_) => _submitForm(),
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
