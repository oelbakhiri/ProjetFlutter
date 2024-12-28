import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../providers/employee_provider.dart';
import 'employee_form_screen.dart';
import 'employee_detail_screen.dart';
import 'task_calendar_screen.dart'; // Assurez-vous d'importer la page du calendrier des tâches

const Color primaryColor = Color.fromARGB(255, 130, 238, 135); // Violet

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Méthode pour gérer la déconnexion
  void _logout() {
    // Logic for logout
    // Par exemple : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Employés',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 33, 157, 22),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'add') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EmployeeFormScreen()),
                );
              } else if (value == 'logout') {
                _logout(); // Logique de déconnexion
              } else if (value == 'calendar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const TaskCalendarScreen()), // Naviguer vers le calendrier des tâches
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'add',
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Ajouter un employé')
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Déconnexion')
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'calendar',
                  child: Row(
                    children: const [
                      Icon(Icons.calendar_today, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Calendrier des tâches')
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onChanged: (value) {
                // Méthode de recherche (à implémenter)
              },
            ),
          ),
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, child) {
                return ListView.builder(
                  itemCount: employeeProvider.employees.length,
                  itemBuilder: (context, index) {
                    final employee = employeeProvider.employees[index];
                    return Slidable(
                      key: Key(employee.id),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              // Action pour modifier l'employé
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmployeeDetailScreen(
                                        employee: employee)),
                              );
                            },
                            backgroundColor:
                                const Color.fromARGB(255, 211, 215, 13),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Modifier',
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              // Action pour supprimer l'employé
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text(
                                        'Voulez-vous vraiment supprimer cet employé ?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Supprimer'),
                                        onPressed: () {
                                          employeeProvider
                                              .deleteEmployee(employee.id);
                                          Navigator.of(context).pop();
                                        },
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: ListTile(
                          title: Text('${employee.nom} ${employee.prenom}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.poste),
                              Text(
                                'Date d\'embauche: ${DateFormat('dd/MM/yyyy').format(employee.dateEmbauche)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EmployeeDetailScreen(employee: employee)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EmployeeFormScreen()));
        },
        backgroundColor: const Color.fromARGB(255, 22, 157, 33),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
