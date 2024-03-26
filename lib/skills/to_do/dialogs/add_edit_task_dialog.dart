import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../methods/priority_methods.dart';
import '../methods/time_methods.dart';
import '../models/task_model.dart';
import '../enums/priority_enum.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final Function closeDialog;

  const EditTaskDialog(this.task, this.closeDialog, {super.key});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final Task _task;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _datePickerController = DateRangePickerController();
  final _formKey = GlobalKey<FormState>();
  Priority _selectedPriority = Priority.none;
  bool _isDialogOpen = false;

  @override
  void initState() {
    _task = widget.task;
    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _selectedPriority = _task.priority;
    _dateController.text = timeToShortString(_task.time);
    _datePickerController.selectedDate = _task.period.plannedStart;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _titleFocusNode.dispose();
    _datePickerController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    _task.description = _descriptionController.text;
    _task.priority = _selectedPriority;
    widget.closeDialog();
  }

  void _showAddEditTaskDialog(int? index, String? parentTaskId) {
    if (_isDialogOpen) return;

    setState(() => _isDialogOpen = true);
    // TODO
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return EditTaskDialog(
    //       _task.subTasks,
    //       index: index,
    //       parentTaskId: parentTaskId,
    //     );
    //   },
    // ).then((_) => setState(() => _isDialogOpen = false));
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
                  PriorityMethods.stringToPriority(_task);
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
            TextField(
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
            InkWell(
              onTap: () => _showAddEditTaskDialog(null, _task.id),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  Text('Add subtask'),
                ],
              ),
            ),
            // SizedBox(
            //   height: 100,
            //   width: 100,
            //   child: TaskList(
            //     _task.subTasks,
            //     (index) => _showAddEditTaskDialog(index, _task.id),
            //     (index) => _completeTask(index, _task.id),
            //   ),
            // ),
            // TODO show all tasks, completed with strikethrough
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitForm,
          child: const Text('Ok'),
        )
      ],
    );
  }
}
