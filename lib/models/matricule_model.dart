/// Modèle pour les matricules d'employés
class Matricule {
  final String id;
  final String matricule;
  final String nom;
  final String prenom;
  final String poste;
  final String department;
  final bool isUsed;
  final String? userId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? usedAt;

  Matricule({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.poste,
    required this.department,
    required this.isUsed,
    this.userId,
    required this.createdBy,
    required this.createdAt,
    this.usedAt,
  });

  /// Helper to extract ID from String or Map
  static String _extractId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['id']?.toString() ?? value['name']?.toString() ?? '';
    }
    return value.toString();
  }

  /// Créer depuis JSON
  factory Matricule.fromJson(Map<String, dynamic> json) {
    return Matricule(
      id: _extractId(json['_id'] ?? json['id']),
      matricule: json['matricule']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      poste: json['poste']?.toString() ?? '',
      department: _extractId(json['department']),
      isUsed: json['isUsed'] ?? false,
      userId: json['userId'] != null ? _extractId(json['userId']) : null,
      createdBy: _extractId(json['createdBy']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      usedAt: json['usedAt'] != null 
          ? DateTime.parse(json['usedAt']) 
          : null,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'poste': poste,
      'department': department,
      'isUsed': isUsed,
      'userId': userId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
    };
  }

  /// Copier avec modifications
  Matricule copyWith({
    String? id,
    String? matricule,
    String? nom,
    String? prenom,
    String? poste,
    String? department,
    bool? isUsed,
    String? userId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? usedAt,
  }) {
    return Matricule(
      id: id ?? this.id,
      matricule: matricule ?? this.matricule,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      poste: poste ?? this.poste,
      department: department ?? this.department,
      isUsed: isUsed ?? this.isUsed,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  /// Nom complet
  String get nomComplet => '$prenom $nom';

  /// Statut en français
  String get statut => isUsed ? 'Utilisé' : 'Disponible';

  @override
  String toString() => 'Matricule($matricule - $nomComplet - $department)';
}

/// Résultat de vérification de matricule
class MatriculeCheckResult {
  final bool exists;
  final bool available;
  final String? nom;
  final String? prenom;
  final String? poste;
  final String? department;

  MatriculeCheckResult({
    required this.exists,
    required this.available,
    this.nom,
    this.prenom,
    this.poste,
    this.department,
  });

  factory MatriculeCheckResult.fromJson(Map<String, dynamic> json) {
    return MatriculeCheckResult(
      exists: json['exists'] ?? false,
      available: json['available'] ?? false,
      nom: json['nom'],
      prenom: json['prenom'],
      poste: json['poste'],
      department: json['department'],
    );
  }

  bool get isValid => exists && available;
}

/// Statistiques des matricules
class MatriculeStats {
  final int total;
  final int used;
  final int available;
  final List<DepartmentStat> byDepartment;

  MatriculeStats({
    required this.total,
    required this.used,
    required this.available,
    required this.byDepartment,
  });

  factory MatriculeStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? json;
    return MatriculeStats(
      total: stats['total'] ?? 0,
      used: stats['used'] ?? 0,
      available: stats['available'] ?? 0,
      byDepartment: (stats['byDepartment'] as List<dynamic>?)
              ?.map((e) => DepartmentStat.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DepartmentStat {
  final String department;
  final int total;
  final int used;
  final int available;

  DepartmentStat({
    required this.department,
    required this.total,
    required this.used,
    required this.available,
  });

  factory DepartmentStat.fromJson(Map<String, dynamic> json) {
    return DepartmentStat(
      department: Matricule._extractId(json['_id']),
      total: json['total'] ?? 0,
      used: json['used'] ?? 0,
      available: json['available'] ?? 0,
    );
  }
}
