import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model.dart';

class TaskScreen extends StatefulWidget {
  final Function(Task) onSave;
  final Task? task;

  TaskScreen({required this.onSave, this.task});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _date;
  late String _time;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _name = widget.task?.name ?? '';
    _description = widget.task?.description ?? '';
    _date = widget.task?.date ?? '';
    _time = widget.task?.time ?? '';
    _priority = widget.task?.priority ?? 0;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_date.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_date);
      } catch (e) {
        // If parsing fails, fallback to the current date.
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _date = picked.toLocal().toString().split(' ')[0]; // YYYY-MM-DD format
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_time.isNotEmpty) {
      try {
        final parts = _time.split(':');
        initialTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // If parsing fails, fallback to the current time.
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        _time = picked.format(context); // Format to HH:MM
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemTeal,
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => _name = val!,
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (val) => _description = val!,
                validator: (val) =>
                    val!.isEmpty ? 'Description is required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                      controller: TextEditingController(text: _date),
                      onTap: () => _selectDate(context),
                      validator: (val) =>
                          val!.isEmpty ? 'Date is required' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                      controller: TextEditingController(text: _time),
                      onTap: () => _selectTime(context),
                      validator: (val) =>
                          val!.isEmpty ? 'Time is required' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(child: Text('Low'), value: 0),
                  DropdownMenuItem(child: Text('Average'), value: 1),
                  DropdownMenuItem(child: Text('High'), value: 2),
                ],
                onChanged: (val) => setState(() => _priority = val!),
                decoration: InputDecoration(labelText: 'Priority'),
                validator: (val) => val == null ? 'Priority is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onSave(Task(
                      id: widget.task?.id,
                      name: _name,
                      description: _description,
                      date: _date,
                      time: _time,
                      priority: _priority,
                      isCompleted: widget.task?.isCompleted ?? false,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
