import 'package:flutter/material.dart';
import 'package:jarvis_2/skills/to_do/methods/priority_methods.dart';
import 'package:jarvis_2/skills/to_do/methods/time_methods.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../firestore/firestore_methods.dart';
import '../models/task_model.dart';
import '../enums/priority_enum.dart';

class AddEditTaskDialog extends StatefulWidget {
  final Map<String, Task> tasks;
  final int? index; // if null this is a new task
  const AddEditTaskDialog(this.tasks, {this.index, super.key});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  late final Task _task;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Priority _selectedPriority = Priority.none;
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  final DateRangePickerController _datePickerController =
      DateRangePickerController();

  @override
  void initState() {
    if (widget.index == null) {
      _task = Task();
    } else {
      _task = widget.tasks.values.elementAt(widget.index!);
      _titleController.text = _task.title;
      _descriptionController.text = _task.description;
      _selectedPriority = _task.priority;
      _dateController.text = timeToShortString(_task.time);
      _datePickerController.selectedDate = _task.period.plannedStart;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _task.description = _descriptionController.text;
      if (widget.index == null) {
        Firestore.addTask(_task).then((taskId) {
          if (taskId.isNotEmpty) {
            _task.id = taskId;
            widget.tasks.addAll({taskId: _task});
            Navigator.of(context).pop();
            _titleController.clear();
            _descriptionController.clear();
          }
        });
      } else {
        Firestore.updateTask(_task).then((success) {
          if (success) {
            Navigator.of(context).pop();
          }
        });
      }
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
            // TODO show this only when editing, make it work or to plan button if no planned starting date
            const LinearProgressIndicator(
              value: 0.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              backgroundColor: Colors.red,
            ),
            TextFormField(
              controller: _titleController,
              onFieldSubmitted: (_) => _submitForm(),
              autofocus: true,
              focusNode: _titleFocusNode,
              decoration: const InputDecoration(hintText: 'Title'),
              onChanged: (value) {
                setState(() {
                  _task.title = value;
                  stringToTime(_task);
                  stringToPriority(_task);
                  _datePickerController.selectedDate =
                      _task.period.plannedStart;
                  _dateController.text = timeToShortString(_task.time);
                });
              },
              validator: (value) {
                if (_task.title.isEmpty) {
                  _titleFocusNode.requestFocus();
                  return 'Title cannot be empty after processing';
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
                        child: Text(priority.string),
                      ))
                  .toList(),
            ),
            Expanded(
              child: TextField(
                controller: _dateController,
                onSubmitted: (_) => _submitForm,
                decoration: const InputDecoration(hintText: 'Planned'),
                onChanged: (value) {
                  setState(() {
                    taskToTime(_dateController.text, _task.time, []);
                    _datePickerController.selectedDate =
                        _task.period.plannedStart;
                  });
                },
              ),
            ),
            SizedBox(
              width: 500,
              height: 400,
              // TODO find a way to show all options of dates
              child: SfDateRangePicker(
                onSelectionChanged: (value) {
                  if (value.value is PickerDateRange) {
                    final range = value.value as PickerDateRange;
                    _task.period.plannedStart = range.startDate;
                    _task.period.plannedEnd = range.endDate;
                  }
                },
                controller: _datePickerController,
                selectionMode: DateRangePickerSelectionMode.single,
                initialSelectedRange: _task.pickerPeriod,
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
