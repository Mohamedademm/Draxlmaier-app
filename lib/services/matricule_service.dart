import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/matricule_model.dart';

/// Service pour gérer les matricules
class MatriculeService {
  final _storage = const FlutterSecureStorage();

  /// Obtenir le token d'authentification
  Future<String?> _getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  /// Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Créer un nouveau matricule
  Future<Matricule> createMatricule({
    required String matricule,
    required String nom,
    required String prenom,
    required String poste,
    required String department,
  }) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/matricules/create'),
      headers: headers,
      body: jsonEncode({
        'matricule': matricule,
        'nom': nom,
        'prenom': prenom,
        'poste': poste,
        'department': department,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Matricule.fromJson(data['data']['matricule']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la création du matricule');
    }
  }

  /// Créer plusieurs matricules en masse
  Future<Map<String, int>> bulkCreateMatricules(List<Map<String, String>> matricules) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/matricules/bulk-create'),
      headers: headers,
      body: jsonEncode({'matricules': matricules}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'inserted': data['data']['inserted'] ?? 0,
        'total': data['data']['total'] ?? 0,
      };
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la création en masse');
    }
  }

  /// Importer des matricules depuis Excel
  Future<Map<String, int>> importExcel(List<Map<String, String>> matricules) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/matricules/import-excel'),
      headers: headers,
      body: jsonEncode({'matricules': matricules}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'imported': data['data']['imported'] ?? 0,
        'total': data['data']['total'] ?? 0,
        'errors': data['data']['errors'] ?? 0,
      };
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'import');
    }
  }

  /// Obtenir tous les matricules avec filtres
  Future<List<Matricule>> getAllMatricules({
    String? status, // 'available' ou 'used'
    String? department,
    String? search,
  }) async {
    final headers = await _getHeaders();
    
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (department != null) queryParams['department'] = department;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('${ApiConstants.baseUrl}/matricules')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📦 API Response status: ${data['status']}');
      print('📦 API Response results: ${data['results']}');
      
      final matriculesData = data['data']['matricules'];
      print('📦 Matricules data type: ${matriculesData.runtimeType}');
      print('📦 Matricules count: ${(matriculesData as List).length}');
      
      final matricules = (matriculesData as List)
          .map((m) {
            try {
              print('🔍 Parsing matricule: ${m['matricule']}');
              final parsed = Matricule.fromJson(m);
              print('✅ Successfully parsed: ${parsed.matricule}');
              return parsed;
            } catch (e, stackTrace) {
              print('❌ Error parsing matricule: $m');
              print('❌ Error details: $e');
              print('❌ Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
      print('✅ Total matricules parsed: ${matricules.length}');
      return matricules;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la récupération');
    }
  }

  /// Obtenir les matricules disponibles uniquement
  Future<List<Matricule>> getAvailableMatricules({String? department}) async {
    final headers = await _getHeaders();
    
    final queryParams = <String, String>{};
    if (department != null) queryParams['department'] = department;

    final uri = Uri.parse('${ApiConstants.baseUrl}/matricules/available')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final matricules = (data['data']['matricules'] as List)
          .map((m) => Matricule.fromJson(m))
          .toList();
      return matricules;
    } else {
      throw Exception('Erreur lors de la récupération des matricules disponibles');
    }
  }

  /// Vérifier un matricule et récupérer les infos
  Future<MatriculeCheckResult> checkMatricule(String matricule) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/matricules/check/$matricule'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return MatriculeCheckResult.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      return MatriculeCheckResult(
        exists: false,
        available: false,
      );
    } else if (response.statusCode == 400) {
      return MatriculeCheckResult(
        exists: true,
        available: false,
      );
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la vérification');
    }
  }

  /// Mettre à jour un matricule
  Future<Matricule> updateMatricule({
    required String id,
    String? nom,
    String? prenom,
    String? poste,
    String? department,
  }) async {
    final headers = await _getHeaders();
    
    final body = <String, String>{};
    if (nom != null) body['nom'] = nom;
    if (prenom != null) body['prenom'] = prenom;
    if (poste != null) body['poste'] = poste;
    if (department != null) body['department'] = department;

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/matricules/$id'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Matricule.fromJson(data['data']['matricule']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la mise à jour');
    }
  }

  /// Supprimer un matricule
  Future<void> deleteMatricule(String id) async {
    final headers = await _getHeaders();
    
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/matricules/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de la suppression');
    }
  }

  /// Obtenir les statistiques
  Future<MatriculeStats> getStats() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/matricules/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MatriculeStats.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques');
    }
  }
}
