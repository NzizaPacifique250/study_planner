// Add this to your pubspec.yaml dependencies:
// table_calendar: ^3.0.9

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_task_page.dart';
import 'task.dart';

class CalendarScreen extends StatefulWidget {
  final List tasks;
  final Future<void> Function(Task) onAddTask;
  final Future<void> Function(Task) onDeleteTask;
  final Future<void> Function(Task, Task) onEditTask;
  const CalendarScreen({Key? key, required this.tasks, required this.onAddTask, required this.onDeleteTask, required this.onEditTask}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final selectedDay = _selectedDay ?? _focusedDay;
    final tasksForSelectedDay = widget.tasks.where((task) {
      final taskDate = task.dueDate;
      return taskDate.year == selectedDay.year &&
          taskDate.month == selectedDay.month &&
          taskDate.day == selectedDay.day;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        title: const Text('My Study Planner', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC700),
        foregroundColor: const Color(0xFF0A2342),
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(
                initialDate: selectedDay,
              ),
            ),
          );
          if (result != null) {
            await widget.onAddTask(result);
            setState(() {});
          }
        },
        tooltip: 'Add Task',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFFFFC700),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF0A2342),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(color: Color(0xFF0A2342)),
                        weekendTextStyle: const TextStyle(color: Color(0xFF0A2342)),
                        outsideTextStyle: const TextStyle(color: Colors.grey),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF0A2342),
                        ),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF0A2342)),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF0A2342)),
                        decoration: const BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320, // Fixed height for the task list container
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: tasksForSelectedDay.isNotEmpty
                      ? ListView.builder(
                          itemCount: tasksForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final task = tasksForSelectedDay[index];
                            return Dismissible(
                              key: ValueKey(task.hashCode),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 24),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Delete
                                  await widget.onDeleteTask(task);
                                  setState(() {});
                                  return true;
                                } else if (direction == DismissDirection.endToStart) {
                                  // Edit
                                  final edited = await Navigator.push<Task?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTaskPage(
                                        existingTask: task,
                                        onTaskAdded: (t) {},
                                      ),
                                    ),
                                  );
                                  if (edited != null) {
                                    await widget.onEditTask(task, edited);
                                    setState(() {});
                                  }
                                  return false;
                                }
                                return false;
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.circle, size: 10, color: Color(0xFF0A2342)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                                          ),
                                          if (task.description != null && task.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2.0),
                                              child: Text(
                                                task.description!,
                                                style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0A2342)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                                                ),
                                                if (task.dueDate.hour != 0 || task.dueDate.minute != 0) ...[
                                                  const SizedBox(width: 12),
                                                  const Icon(Icons.access_time, size: 16, color: Color(0xFF0A2342)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (task.reminderTime != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.notifications_active, size: 16, color: Color(0xFFFFC700)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Reminder: ${task.reminderTime!.year}-${task.reminderTime!.month.toString().padLeft(2, '0')}-${task.reminderTime!.day.toString().padLeft(2, '0')} '
                                                    '${task.reminderTime!.hour.toString().padLeft(2, '0')}:${task.reminderTime!.minute.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Column(
                          children: [
                            const Text(
                              'No tasks for this day.',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTaskPage(
                                        onTaskAdded: (task) {},
                                        initialDate: selectedDay,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    await widget.onAddTask(result);
                                    setState(() {});
                                  }
                                },
                                child: const Text('New Task'),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
