import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskStorage {
  static const String _key = 'tasks';
  static const String _shownRemindersKey = 'shown_reminders';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<Set<String>> loadShownReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shownRemindersKey);
    if (jsonString == null) return <String>{};
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => e.toString()).toSet();
  }

  static Future<void> saveShownReminders(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shownRemindersKey, json.encode(ids.toList()));
  }
}
