import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../methods/priority_methods.dart';
import '../methods/time_methods.dart';
import '../models/task_model.dart';
import '../enums/priority_enum.dart';
import '../widgets/task_list_and_add.dart';

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
  final _dateFocusNode = FocusNode();
  final _datePickerController = DateRangePickerController();
  final _formKey = GlobalKey<FormState>();
  Priority _selectedPriority = Priority.none;

  @override
  void initState() {
    _task = widget.task;
    _titleController.text = _task.title;
    _descriptionController.text = _task.description;
    _selectedPriority = _task.priority;
    _dateController.text = timeToShortString(_task.time);
    _datePickerController.selectedDate = _task.period.plannedStart;
    _dateFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _titleFocusNode.dispose();
    _datePickerController.dispose();
    _dateFocusNode.removeListener(() {});
    _dateFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    _task.description = _descriptionController.text;
    _task.priority = _selectedPriority;
    widget.closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: FractionallySizedBox(
          heightFactor: 1,
          child: SingleChildScrollView(
            // TODO find a bettwe way to handle column renderFlex overflow when hiding keyboard
            child: Column(
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
                Stack(
                  children: [
                    TextField(
                      controller: _dateController,
                      onSubmitted: (_) => _submitForm,
                      focusNode: _dateFocusNode,
                      decoration: const InputDecoration(hintText: 'Planned'),
                      onChanged: (value) {
                        setState(() {
                          taskToTime(_dateController.text, _task.time, []);
                          _datePickerController.selectedDate =
                              _task.period.plannedStart;
                        });
                      },
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _task.period.plannedStart,
                            firstDate:
                                min(DateTime.now(), _task.period.plannedStart),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                _task.period.plannedStart = value;
                                _dateController.text =
                                    timeToShortString(_task.time);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // TODO show this only for pc
                // !_dateFocusNode.hasFocus
                //     ? const SizedBox()
                //     : SizedBox(
                //         width: 500,
                //         height: 400,
                //         // TODO find a way to show all options of dates
                //         child: SfDateRangePicker(
                //           onSelectionChanged: (value) {
                //             if (value.value is PickerDateRange) {
                //               final range = value.value as PickerDateRange;
                //               _task.period.plannedStart = range.startDate;
                //               _task.period.plannedEnd = range.endDate;
                //             }
                //           },
                //           controller: _datePickerController,
                //           selectionMode: DateRangePickerSelectionMode.single,
                //           initialSelectedRange: _task.pickerPeriod,
                //         ),
                //       ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.57,
                  // if the keyboard is open, make the height smaller
                  height: MediaQuery.of(context).size.height * 0.56 -
                      MediaQuery.of(context).viewInsets.bottom,
                  // height: MediaQuery.of(context).size.height * 0.48,
                  // TODO solve this for web
                  // width: 500,
                  width: MediaQuery.of(context).size.width,
                  child: TaskListAndAdd(
                    _task.subTasks,
                    parentTaskId: _task.id,
                  ),
                ),
                // TODO show all tasks, completed with strikethrough
              ],
            ),
          ),
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
