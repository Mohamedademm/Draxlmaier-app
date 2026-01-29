import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/team_provider.dart';
import '../services/objective_service.dart';
import '../models/user_model.dart';
import '../utils/department_constants.dart';

/// Manager Objectives Management Screen
/// Allows managers to create and assign objectives to employees or departments
class ManagerObjectivesScreen extends StatefulWidget {
  const ManagerObjectivesScreen({super.key});

  @override
  State<ManagerObjectivesScreen> createState() => _ManagerObjectivesScreenState();
}

class _ManagerObjectivesScreenState extends State<ManagerObjectivesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectiveService = ObjectiveService();
  
  // New: Type selection
  String _assignmentType = 'employee'; // 'employee' or 'department'
  
  String? _selectedEmployeeId;
  String? _selectedDepartment;
  String _selectedPriority = 'medium';
  DateTime? _deadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  Future<void> _loadEmployees() async {
    final userProvider = context.read<UserProvider>();
    final teamProvider = context.read<TeamProvider>();
    
    print('Loading users and departments...');
    await Future.wait([
      userProvider.loadUsers(),
      teamProvider.loadDepartments(),
    ]);
    print('Users loaded: ${userProvider.users.length}');
    print('Departments loaded: ${teamProvider.departments.length}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _createObjective() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation based on assignment type
    if (_assignmentType == 'employee') {
      if (_selectedEmployeeId == null) {
        _showSnackBar('Veuillez sélectionner un employé', Colors.orange);
        return;
      }
    } else {
      if (_selectedDepartment == null) {
        _showSnackBar('Veuillez sélectionner un département', Colors.orange);
        return;
      }
    }

    if (_deadline == null) {
      _showSnackBar('Veuillez sélectionner une date limite', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_assignmentType == 'employee') {
        // Create objective for single employee
        await _objectiveService.createObjective(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          startDate: DateTime.now(),
          dueDate: _deadline!,
          assignedToId: _selectedEmployeeId!,
        );
        
        if (mounted) {
          _showSnackBar('Objectif créé avec succès!', const Color(0xFF10B981));
          Navigator.pop(context);
        }
      } else {
        // Create ONE department objective (not multiple)
        final userProvider = context.read<UserProvider>();
        final teamProvider = context.read<TeamProvider>();
        
        // Find department name for employee filtering
        final departmentObj = teamProvider.departments.firstWhere(
          (d) => d.id == _selectedDepartment,
          orElse: () => throw Exception('Department not found'), 
        );
        
        // Filter using department NAME because UserModel stores department as a String name
        final departmentEmployees = userProvider.users
            .where((user) => 
                user.role == UserRole.employee && 
                user.department == departmentObj.name) // Use name from object
            .toList();

        if (departmentEmployees.isEmpty) {
          _showSnackBar(
            'Aucun employé trouvé dans le département ${departmentObj.name}', 
            Colors.orange
          );
          setState(() => _isLoading = false);
          return;
        }

        // Use the first employee as representative for the department objective
        // The department field will indicate it's a department-wide objective
        await _objectiveService.createObjective(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          startDate: DateTime.now(),
          dueDate: _deadline!,
          assignedToId: departmentEmployees.first.id,
          departmentId: _selectedDepartment, // This sends the ID (ObjectId)
        );

        if (mounted) {
          _showSnackBar(
            'Objectif créé pour le département ${departmentObj.name}!',
            const Color(0xFF10B981),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur: $e', const Color(0xFFEF4444));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == const Color(0xFF10B981)
                  ? Icons.check_circle_rounded
                  : backgroundColor == const Color(0xFFEF4444)
                      ? Icons.error_rounded
                      : Icons.warning_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Créer un objectif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter employees only
          final employees = userProvider.users
              .where((user) => user.role == UserRole.employee)
              .toList();
          
          print('Total users: ${userProvider.users.length}');
          print('Employees found: ${employees.length}');

          if (employees.isEmpty && !userProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun employé trouvé',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Veuillez d\'abord créer des employés'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadEmployees,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Assignment Type Selection - NEW
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.category_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Type d\'assignation',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0EA5E9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTypeOption(
                                        type: 'employee',
                                        icon: Icons.person_rounded,
                                        title: 'Employé',
                                        subtitle: 'Une personne',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTypeOption(
                                        type: 'department',
                                        icon: Icons.group_work_rounded,
                                        title: 'Département',
                                        subtitle: 'Toute l\'équipe',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Employee or Department Selection
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _assignmentType == 'employee' 
                                            ? Icons.person_search_rounded 
                                            : Icons.business_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _assignmentType == 'employee'
                                          ? 'Sélectionner un employé'
                                          : 'Sélectionner un département',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0EA5E9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_assignmentType == 'employee')
                                  _buildModernEmployeeDropdown(employees)
                                else
                                  _buildModernDepartmentDropdown(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Objective Details
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Détails de l\'objectif',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0EA5E9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Title
                                _buildModernTextField(
                                  controller: _titleController,
                                  label: 'Titre',
                                  icon: Icons.title_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Le titre est requis';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Description
                                _buildModernTextField(
                                  controller: _descriptionController,
                                  label: 'Description',
                                  icon: Icons.description_rounded,
                                  maxLines: 4,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'La description est requise';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Priority
                                _buildModernPriorityDropdown(),
                                const SizedBox(height: 16),

                                // Deadline
                                _buildModernDatePicker(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Create Button
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 900),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: _isLoading ? null : _createObjective,
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                height: 60,
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                                          SizedBox(width: 12),
                                          Text(
                                            'Créer l\'objectif',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper: Build Type Selection Option
  Widget _buildTypeOption({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _assignmentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _assignmentType = type;
          // Reset selections when switching types
          _selectedEmployeeId = null;
          _selectedDepartment = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Build Modern Employee Dropdown
  Widget _buildModernEmployeeDropdown(List<User> employees) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEmployeeId,
        decoration: InputDecoration(
          hintText: 'Choisir un employé',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: employees.map((employee) {
          return DropdownMenuItem(
            value: employee.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.2),
                  child: Text(
                    employee.firstname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0EA5E9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${employee.firstname} ${employee.lastname}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        employee.department ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedEmployeeId = value;
          });
        },
      ),
    );
  }

  // Helper: Build Modern Department Dropdown with Dynamic Data
  Widget _buildModernDepartmentDropdown() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, _) {
        if (teamProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final departments = teamProvider.departments;
        
        if (departments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Aucun département trouvé')),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0EA5E9).withOpacity(0.1),
                const Color(0xFF06B6D4).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF0EA5E9).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              hintText: 'Choisir un département',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_rounded, color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            items: departments.map((department) {
              return DropdownMenuItem(
                value: department.id, // Use ID as value
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (department.color != null && department.color!.isNotEmpty)
                            ? Color(int.parse(department.color!.replaceFirst('#', '0xFF')))
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.apartment, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        department.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un département';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  // Helper: Build Modern Text Field
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF0EA5E9),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  // Helper: Build Modern Priority Dropdown
  Widget _buildModernPriorityDropdown() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedPriority,
        decoration: InputDecoration(
          labelText: 'Priorité',
          labelStyle: const TextStyle(
            color: Color(0xFF0EA5E9),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: [
          _buildPriorityItem('low', 'Basse', Colors.green),
          _buildPriorityItem('medium', 'Moyenne', Colors.orange),
          _buildPriorityItem('high', 'Haute', Colors.red),
          _buildPriorityItem('urgent', 'Urgente', Colors.purple),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPriority = value!;
          });
        },
      ),
    );
  }

  DropdownMenuItem<String> _buildPriorityItem(String value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Helper: Build Modern Date Picker
  Widget _buildModernDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0EA5E9).withOpacity(0.1),
              const Color(0xFF06B6D4).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF0EA5E9).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date limite',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0EA5E9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _deadline != null
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _deadline != null ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}