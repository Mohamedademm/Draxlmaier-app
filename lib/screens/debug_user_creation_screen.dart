import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class DebugUserCreationScreen extends StatefulWidget {
  const DebugUserCreationScreen({Key? key}) : super(key: key);

  @override
  State<DebugUserCreationScreen> createState() => _DebugUserCreationScreenState();
}

class _DebugUserCreationScreenState extends State<DebugUserCreationScreen> {
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();
  String _debugLog = '';

  void _addLog(String message) {
    setState(() {
      _debugLog += '\n$message';
    });
    print('[DEBUG] $message');
  }

  Future<void> _testCreateUser() async {
    setState(() {
      _debugLog = '';
    });

    try {
      // 1. Vérifier le token
      _addLog('🔍 Vérification du token...');
      final token = await _apiService.getToken();
      if (token == null) {
        _addLog('❌ PAS DE TOKEN TROUVÉ !');
        _addLog('Vous devez être connecté');
        return;
      }
      _addLog('✅ Token trouvé: ${token.substring(0, 30)}...');

      // 2. Tenter de créer l'utilisateur
      _addLog('\n👤 Création d\'un utilisateur test...');
      _addLog('Email: testadmin@gmail.com');
      _addLog('Role: admin');

      final user = await _userService.createUser(
        firstname: 'TestAdmin',
        lastname: 'System',
        email: 'testadmin@gmail.com',
        password: '123456',
        role: UserRole.admin,
      );

      _addLog('\n✅ SUCCÈS !');
      _addLog('Utilisateur créé: ${user.email}');
      _addLog('ID: ${user.id}');
      _addLog('Role: ${user.role.name}');

    } catch (e) {
      _addLog('\n❌ ERREUR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Création Utilisateur'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _testCreateUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'TESTER CRÉATION UTILISATEUR',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Logs de debug:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugLog.isEmpty ? 'Cliquez sur le bouton pour commencer' : _debugLog,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
