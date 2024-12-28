import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';
import 'package:intl/intl.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _posteController;
  late TextEditingController _departementController;
  DateTime _dateEmbauche = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.employee?.nom ?? '');
    _prenomController =
        TextEditingController(text: widget.employee?.prenom ?? '');
    _emailController =
        TextEditingController(text: widget.employee?.email ?? '');
    _telephoneController =
        TextEditingController(text: widget.employee?.telephone ?? '');
    _posteController =
        TextEditingController(text: widget.employee?.poste ?? '');
    _departementController =
        TextEditingController(text: widget.employee?.departement ?? '');
    if (widget.employee != null) {
      _dateEmbauche = widget.employee!.dateEmbauche;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _posteController.dispose();
    _departementController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateEmbauche,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateEmbauche) {
      setState(() {
        _dateEmbauche = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null
            ? 'Ajouter un employé'
            : 'Modifier l\'employé'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _posteController,
                decoration: const InputDecoration(labelText: 'Poste'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un poste';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _departementController,
                decoration: const InputDecoration(labelText: 'Département'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un département';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    'Date d\'embauche: ${DateFormat('dd/MM/yyyy').format(_dateEmbauche)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final employee = Employee(
                      id: widget.employee?.id ?? DateTime.now().toString(),
                      nom: _nomController.text,
                      prenom: _prenomController.text,
                      email: _emailController.text,
                      telephone: _telephoneController.text,
                      poste: _posteController.text,
                      departement: _departementController.text,
                      dateEmbauche: _dateEmbauche,
                    );

                    if (widget.employee == null) {
                      context.read<EmployeeProvider>().addEmployee(employee);
                    } else {
                      context.read<EmployeeProvider>().updateEmployee(employee);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.employee == null ? 'Ajouter' : 'Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
