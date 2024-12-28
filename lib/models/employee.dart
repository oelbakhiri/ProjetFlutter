class Employee {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String poste;
  final String departement;
  final DateTime dateEmbauche;

  Employee({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.poste,
    required this.departement,
    required this.dateEmbauche,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'poste': poste,
      'departement': departement,
      'dateEmbauche': dateEmbauche.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      telephone: map['telephone'],
      poste: map['poste'],
      departement: map['departement'],
      dateEmbauche: DateTime.parse(map['dateEmbauche']),
    );
  }
}
