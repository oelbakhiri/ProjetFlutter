import 'package:flutter/material.dart';
import '../models/employee.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({
    Key? key,
    required this.employee,
  }) : super(key: key);

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _posteController;
  late TextEditingController _departementController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.employee.nom);
    _prenomController = TextEditingController(text: widget.employee.prenom);
    _emailController = TextEditingController(text: widget.employee.email);
    _telephoneController =
        TextEditingController(text: widget.employee.telephone);
    _posteController = TextEditingController(text: widget.employee.poste);
    _departementController =
        TextEditingController(text: widget.employee.departement);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String validationMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedEmployee = Employee(
        id: widget.employee.id,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _telephoneController.text,
        poste: _posteController.text,
        departement: _departementController.text,
        dateEmbauche: widget.employee.dateEmbauche,
      );

      context.read<EmployeeProvider>().updateEmployee(updatedEmployee);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employé mis à jour avec succès')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Modifier ${widget.employee.nom} ${widget.employee.prenom}'),
        backgroundColor: const Color.fromARGB(255, 33, 157, 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nomController,
                labelText: 'Nom',
                validationMessage: 'Veuillez entrer le nom.',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _prenomController,
                labelText: 'Prénom',
                validationMessage: 'Veuillez entrer le prénom.',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                validationMessage: 'Veuillez entrer un email valide.',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telephoneController,
                labelText: 'Téléphone',
                validationMessage: 'Veuillez entrer le téléphone.',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _posteController,
                labelText: 'Poste',
                validationMessage: 'Veuillez entrer le poste.',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _departementController,
                labelText: 'Département',
                validationMessage: 'Veuillez entrer le département.',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 33, 157, 22),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
