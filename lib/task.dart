class Task {
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime? reminderTime;

  Task({
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderTime,
  });
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'reminderTime': reminderTime?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'],
        dueDate: DateTime.parse(json['dueDate']),
        reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      );
}
