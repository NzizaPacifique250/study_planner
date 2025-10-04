import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'task.dart';
import 'task_storage.dart';
import 'add_task_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskStorage.loadTasks();
    setState(() {
      _tasks = loaded;
      _loading = false;
    });
  }

  Future<void> _addTask(Task task) async {
    setState(() {
      _tasks.add(task);
    });
    await TaskStorage.saveTasks(_tasks);
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _tasks.remove(task);
    });
    await TaskStorage.saveTasks(_tasks);
  }

  Future<void> _editTask(Task oldTask, Task newTask) async {
    setState(() {
      final idx = _tasks.indexOf(oldTask);
      if (idx != -1) {
        _tasks[idx] = newTask;
      }
    });
    await TaskStorage.saveTasks(_tasks);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        tasks: _tasks,
        onAddTask: _addTask,
        onDeleteTask: _deleteTask,
        onEditTask: _editTask,
      ),
      CalendarScreen(
        tasks: _tasks,
        onAddTask: _addTask,
        onDeleteTask: _deleteTask,
        onEditTask: _editTask,
      ),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _selectedIndex,
                  children: screens,
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56, // Above the BottomNavigationBar
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(
                  'Developed by Nziza Aime Pacifique',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  final List<Task> tasks;
  final Future<void> Function(Task) onAddTask;
  final Future<void> Function(Task) onDeleteTask;
  final Future<void> Function(Task, Task) onEditTask;
  const TodayScreen({Key? key, required this.tasks, required this.onAddTask, required this.onDeleteTask, required this.onEditTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayTasks = tasks.where((task) =>
      task.dueDate.year == today.year &&
      task.dueDate.month == today.month &&
      task.dueDate.day == today.day
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        title: const Text('Today', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remind Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (todayTasks.isEmpty)
                          const Text('No tasks for today.', style: TextStyle(color: Color(0xFF0A2342))),
                        ...todayTasks.map((task) => Dismissible(
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
                              await onDeleteTask(task);
                              return true;
                            } else if (direction == DismissDirection.endToStart) {
                              // Edit
                              final edited = await Navigator.push<Task?>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTaskPage(
                                    initialDate: task.dueDate,
                                    onTaskAdded: (t) {},
                                  ),
                                ),
                              );
                              if (edited != null) {
                                await onEditTask(task, edited);
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
                        )),
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
                            onPressed: () async {
                              final result = await Navigator.push<Task?>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTaskPage(
                                    initialDate: today,
                                  ),
                                ),
                              );
                              if (result != null) {
                                await onAddTask(result);
                              }
                            },
                            child: const Text('New Task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}


