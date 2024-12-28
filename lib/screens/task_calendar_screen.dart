import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({super.key});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasks();
  }

  void _loadTasks() async {
    if (_selectedDay != null) {
      final tasks =
          await context.read<EmployeeProvider>().getTasksForDate(_selectedDay!);
      setState(() {
        _tasks = tasks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des Tâches',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 33, 157, 22),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadTasks();
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Slidable(
                  key: Key(task.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Voulez-vous vraiment supprimer cette tâche ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<EmployeeProvider>()
                                          .deleteTask(task.id);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Tâche supprimée'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Supprimer',
                      ),
                    ],
                  ),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          Text('Assigné à: ${task.employeeName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              'Heure: ${DateFormat('HH:mm').format(task.date)}'),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          // Update task completion status
                          final updatedTask = Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            date: task.date,
                            employeeId: task.employeeId,
                            employeeName: task.employeeName,
                            isCompleted: value ?? false,
                          );
                          context
                              .read<EmployeeProvider>()
                              .updateTask(updatedTask);
                          _loadTasks();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 33, 157, 22),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    Employee? selectedEmployee;
    final employees = context.read<EmployeeProvider>().employees;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter une tâche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Employee>(
                      decoration: const InputDecoration(
                        labelText: 'Employé',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedEmployee,
                      items: employees.map((Employee employee) {
                        return DropdownMenuItem<Employee>(
                          value: employee,
                          child: Text('${employee.nom} ${employee.prenom}'),
                        );
                      }).toList(),
                      onChanged: (Employee? value) {
                        setState(() {
                          selectedEmployee = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Heure'),
                      trailing: Text(selectedTime.format(context)),
                      onTap: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() {
                            selectedTime = time;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedDay != null &&
                        titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        selectedEmployee != null) {
                      final dateTime = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final task = Task(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        date: dateTime,
                        employeeId: selectedEmployee!.id,
                        employeeName:
                            '${selectedEmployee!.nom} ${selectedEmployee!.prenom}',
                      );

                      context.read<EmployeeProvider>().addTask(task);
                      _loadTasks();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
