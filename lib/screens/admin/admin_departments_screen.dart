import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/department_model.dart';
import '../../models/user_model.dart';
import '../../services/department_service.dart';
import '../../services/user_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/modern_theme.dart';

class AdminDepartmentsScreen extends StatefulWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  State<AdminDepartmentsScreen> createState() => _AdminDepartmentsScreenState();
}

class _AdminDepartmentsScreenState extends State<AdminDepartmentsScreen> {
  final DepartmentService _departmentService = DepartmentService();
  final UserService _userService = UserService();
  
  List<Department> _departments = [];
  List<User> _managers = [];
  bool _isLoading = true;
  bool _showInactiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final departments = await _departmentService.getDepartments(
        isActive: _showInactiveOnly ? false : null,
      );
      final users = await _userService.getAllUsers();
      
      setState(() {
        _departments = departments;
        _managers = users.where((u) => u.role == 'manager' || u.role == 'admin').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final budgetController = TextEditingController();
    final codeController = TextEditingController();
    String? selectedManagerId;
    Color selectedColor = const Color(0xFF4CAF50);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau Département', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du département *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (ex: IT, HR, FIN)',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedManagerId,
                    decoration: const InputDecoration(
                      labelText: 'Manager *',
                      border: OutlineInputBorder(),
                    ),
                    items: _managers.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.firstname} ${user.lastname} (${user.role})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedManagerId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Localisation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Couleur: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      ...[ 
                        Colors.green, Colors.blue, Colors.orange,
                        Colors.purple, Colors.red, Colors.teal
                      ].map((color) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedManagerId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom et Manager requis')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _departmentService.createDepartment(
          name: nameController.text,
          description: descController.text.isEmpty ? null : descController.text,
          managerId: selectedManagerId!,
          location: locationController.text.isEmpty ? null : locationController.text,
          budget: budgetController.text.isEmpty ? null : int.tryParse(budgetController.text),
          color: '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Département et groupe de chat créés avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(Department dept) async {
    final nameController = TextEditingController(text: dept.name);
    final descController = TextEditingController(text: dept.description ?? '');
    final locationController = TextEditingController(text: dept.location ?? '');
    final budgetController = TextEditingController(
      text: dept.budget != null ? dept.budget.toString() : '',
    );
    String? selectedManagerId = dept.manager?.id;
    Color selectedColor = dept.color != null 
        ? Color(int.parse('0xFF${dept.color!.substring(1)}'))
        : const Color(0xFF4CAF50);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier Département', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du département *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedManagerId,
                    decoration: const InputDecoration(
                      labelText: 'Manager *',
                      border: OutlineInputBorder(),
                    ),
                    items: _managers.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.firstname} ${user.lastname}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedManagerId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Localisation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Couleur: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      ...[ 
                        Colors.green, Colors.blue, Colors.orange,
                        Colors.purple, Colors.red, Colors.teal
                      ].map((color) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || selectedManagerId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom et Manager requis')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _departmentService.updateDepartment(
          departmentId: dept.id,
          name: nameController.text,
          description: descController.text.isEmpty ? null : descController.text,
          managerId: selectedManagerId,
          location: locationController.text.isEmpty ? null : locationController.text,
          budget: budgetController.text.isEmpty ? null : int.tryParse(budgetController.text),
          color: '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Département modifié'), backgroundColor: Colors.green),
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(Department dept) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le département "${dept.name}"?\n\n'
          'Le groupe de chat associé sera également désactivé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _departmentService.deleteDepartment(dept.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Département supprimé'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accès refusé')),
        body: const Center(child: Text('Accès réservé aux administrateurs')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Gestion des Départements'),
        backgroundColor: ModernTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_departments.length} département(s)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilterChip(
                        label: Text(_showInactiveOnly ? 'Inactifs' : 'Tous'),
                        selected: _showInactiveOnly,
                        onSelected: (selected) {
                          setState(() => _showInactiveOnly = selected);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _departments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun département',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Créez un nouveau département',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _departments.length,
                          itemBuilder: (context, index) {
                            final dept = _departments[index];
                            final deptColor = dept.color != null
                                ? Color(int.parse('0xFF${dept.color!.substring(1)}'))
                                : const Color(0xFF4CAF50);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: deptColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.business, color: deptColor, size: 28),
                                ),
                                title: Text(
                                  dept.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (dept.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(dept.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          dept.manager != null 
                                              ? '${dept.manager!.firstname} ${dept.manager!.lastname}'
                                              : 'Aucun manager',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    if (dept.location != null || dept.employeeCount != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (dept.location != null) ...[
                                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              dept.location!,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          if (dept.employeeCount != null) ...[
                                            Icon(Icons.people, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${dept.employeeCount} employés',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!dept.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Inactif',
                                          style: TextStyle(fontSize: 11, color: Colors.red),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: ModernTheme.primary),
                                      onPressed: () => _showEditDialog(dept),
                                      tooltip: 'Modifier',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(dept),
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: ModernTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Département'),
      ),
    );
  }
}
