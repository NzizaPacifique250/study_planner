import 'package:flutter/material.dart';
import 'task.dart';

class AddTaskPage extends StatefulWidget {
  final Function(Task)? onTaskAdded;
  final DateTime? initialDate;
  const AddTaskPage({Key? key, this.onTaskAdded, this.initialDate}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _description;
  DateTime? _dueDate;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _dueDate = widget.initialDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasTime = _dueDate != null && (_dueDate!.hour != 0 || _dueDate!.minute != 0);
    bool enableReminder = _reminderTime != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('New Task', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                        onSaved: (value) => _title = value!,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0A2342)),
                            ),
                            controller: TextEditingController(
                              text: _dueDate == null
                                  ? ''
                                  : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}',
                            ),
                            validator: (value) => _dueDate == null ? 'Date is required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                          Switch(
                            value: hasTime,
                            activeColor: const Color(0xFFFFC700),
                            onChanged: (val) async {
                              if (val) {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null && _dueDate != null) {
                                  setState(() {
                                    _dueDate = DateTime(
                                      _dueDate!.year,
                                      _dueDate!.month,
                                      _dueDate!.day,
                                      picked.hour,
                                      picked.minute,
                                    );
                                  });
                                }
                              } else {
                                setState(() {
                                  if (_dueDate != null) {
                                    _dueDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (hasTime && _dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF0A2342)),
                              const SizedBox(width: 8),
                              Text(
                                '${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Notify me 1 day before', style: TextStyle(color: Color(0xFF0A2342))),
                          Switch(
                            value: enableReminder,
                            activeColor: const Color(0xFFFFC700),
                            onChanged: (val) async {
                              if (val && _dueDate != null) {
                                // Default reminder time: 8:00 AM the day before
                                final defaultReminder = DateTime(
                                  _dueDate!.year,
                                  _dueDate!.month,
                                  _dueDate!.day - 1,
                                  8, 0,
                                );
                                setState(() => _reminderTime = defaultReminder);
                              } else {
                                setState(() => _reminderTime = null);
                              }
                            },
                          ),
                        ],
                      ),
                      if (enableReminder && _reminderTime != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (_dueDate == null) return;
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: _reminderTime!.hour, minute: _reminderTime!.minute),
                              );
                              if (picked != null) {
                                // Ensure reminder date is not after task date
                                final reminderDate = DateTime(
                                  _dueDate!.year,
                                  _dueDate!.month,
                                  _dueDate!.day - 1,
                                  picked.hour,
                                  picked.minute,
                                );
                                if (reminderDate.isAfter(_dueDate!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reminder time must be before the task date.')),
                                  );
                                } else {
                                  setState(() => _reminderTime = reminderDate);
                                }
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.alarm, color: Color(0xFF0A2342)),
                                const SizedBox(width: 8),
                                Text(
                                  '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                                ),
                                const SizedBox(width: 8),
                                const Text('(Tap to change)', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC700),
                            foregroundColor: const Color(0xFF0A2342),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _dueDate != null) {
                              _formKey.currentState!.save();
                              final task = Task(
                                title: _title,
                                description: _description,
                                dueDate: _dueDate!,
                                reminderTime: _reminderTime,
                              );
                              if (widget.onTaskAdded != null) {
                                widget.onTaskAdded!(task);
                              }
                              Navigator.pop(context, task);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
