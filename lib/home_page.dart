import 'package:flutter/material.dart';

import 'calendar_screen.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(tasks: _tasks, onAddTask: _addTask),
      CalendarScreen(tasks: _tasks, onAddTask: _addTask),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: screens,
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
  const TodayScreen({Key? key, required this.tasks, required this.onAddTask}) : super(key: key);

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
                        'Remind 4sasks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (todayTasks.isEmpty)
                        const Text('No tasks for today.', style: TextStyle(color: Color(0xFF0A2342))),
                      ...todayTasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFF0A2342))),
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(fontSize: 16, color: Color(0xFF0A2342)),
                              ),
                            ),
                          ],
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
    );
  }
}



class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings will appear here.')),
    );
  }
}
