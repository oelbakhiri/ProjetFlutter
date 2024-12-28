class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final String employeeId;
  final String employeeName;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.employeeId,
    required this.employeeName,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'employeeId': employeeId,
      'employeeName': employeeName,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
      employeeId: map['employeeId'],
      employeeName: map['employeeName'],
    );
  }
}
