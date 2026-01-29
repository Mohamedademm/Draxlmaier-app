import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matricule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/matricule_model.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

/// Écran de gestion des matricules (Admin/Manager uniquement)
class MatriculeManagementScreen extends StatefulWidget {
  const MatriculeManagementScreen({super.key});

  @override
  State<MatriculeManagementScreen> createState() => _MatriculeManagementScreenState();
}

class _MatriculeManagementScreenState extends State<MatriculeManagementScreen> with SingleTickerProviderStateMixin {
  String? _statusFilter;
  String? _departmentFilter;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final DepartmentService _departmentService = DepartmentService();
  List<Department> _departments = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<MatriculeProvider>();
    
    // Load departments first
    try {
      final departments = await _departmentService.getDepartments();
      if (mounted) {
        setState(() {
          _departments = departments;
        });
      }
    } catch (e) {
      print('Error loading departments: $e');
    }

    await Future.wait([
      provider.loadMatricules(),
      provider.loadStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final matriculeProvider = context.watch<MatriculeProvider>();

    if (!authProvider.isAdmin && !authProvider.isManager) {
      return const Scaffold(
        appBar: ModernAppBar(title: 'Gestion des Matricules'),
        body: Center(
          child: EmptyState(
            icon: Icons.lock_outline,
            title: 'Accès Refusé',
            message: 'Cette section est réservée aux administrateurs.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(ModernTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matriculeProvider.stats != null) ...[
                      _buildStats(matriculeProvider.stats!),
                      const SizedBox(height: ModernTheme.spacingL),
                    ],
                    _buildFilters(matriculeProvider),
                    const SizedBox(height: ModernTheme.spacingM),
                  ],
                ),
              ),
            ),
          ),
          _buildMatriculeList(matriculeProvider),
        ],
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateDialog(),
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Nouveau Matricule',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0EA5E9),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Gestion des Matricules',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF06B6D4),
                Color(0xFF0891B2),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -30,
                child: Icon(
                  Icons.badge_outlined,
                  size: 200,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -40,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 150,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ),
      ],
    );
  }

  Widget _buildStats(MatriculeStats stats) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        stats.total.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Total Matricules',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        stats.used.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Utilisés',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        stats.available.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Disponibles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(MatriculeProvider provider) {
    // Use dynamic departments list
    final departments = _departments.map((d) => d.name).toList();
    if (departments.isEmpty) {
        // Fallback if loading fails or empty
        departments.addAll(['Qualité', 'Logistique', 'MM Shift A', 'MM Shift B', 'SZB Shift A', 'SZB Shift B']);
    }
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0EA5E9).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un matricule ou un nom...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            onChanged: (val) {
              provider.setFilters(
                status: _statusFilter,
                department: _departmentFilter,
                search: val,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withOpacity(0.1),
                      const Color(0xFF06B6D4).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    hint: Row(
                      children: [
                        const Icon(Icons.filter_list_rounded, color: Color(0xFF0EA5E9), size: 18),
                        const SizedBox(width: 8),
                        Text('Statut', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0EA5E9)),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tous les statuts')),
                      DropdownMenuItem(
                        value: 'available',
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded, color: Color(0xFFF59E0B), size: 18),
                            SizedBox(width: 8),
                            Text('Disponibles'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'used',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                            SizedBox(width: 8),
                            Text('Utilisés'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                      provider.setFilters(status: value, department: _departmentFilter, search: _searchController.text);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withOpacity(0.1),
                      const Color(0xFF06B6D4).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _departmentFilter,
                    hint: Row(
                      children: [
                        const Icon(Icons.business_rounded, color: Color(0xFF0EA5E9), size: 18),
                        const SizedBox(width: 8),
                        Text('Département', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0EA5E9)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous les dépts')),
                      ...departments.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (value) {
                      setState(() => _departmentFilter = value);
                      provider.setFilters(status: _statusFilter, department: value, search: _searchController.text);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatriculeList(MatriculeProvider provider) {
    if (provider.isLoading && provider.matricules.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.matricules.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'Aucun résultat',
          message: 'Aucun matricule ne correspond à vos critères.',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final matricule = provider.matricules[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: matricule.isUsed 
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFF59E0B).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (matricule.isUsed 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFFF59E0B)).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: matricule.isUsed 
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (matricule.isUsed 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFF59E0B)).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        matricule.matricule.isNotEmpty 
                            ? matricule.matricule.substring(0, 1).toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${matricule.matricule} • ${matricule.nomComplet}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.work_outline_rounded,
                              size: 14,
                              color: Color(0xFF0EA5E9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${matricule.poste} | ${matricule.department}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: matricule.isUsed
                                ? [
                                    const Color(0xFF10B981).withOpacity(0.2),
                                    const Color(0xFF059669).withOpacity(0.1),
                                  ]
                                : [
                                    const Color(0xFFF59E0B).withOpacity(0.2),
                                    const Color(0xFFD97706).withOpacity(0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              matricule.isUsed 
                                  ? Icons.check_circle_rounded 
                                  : Icons.schedule_rounded,
                              size: 16,
                              color: matricule.isUsed 
                                  ? const Color(0xFF10B981) 
                                  : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              matricule.statut.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: matricule.isUsed 
                                    ? const Color(0xFF10B981) 
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: !matricule.isUsed
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Color(0xFF0EA5E9),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Color(0xFF0EA5E9),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Modifier',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Supprimer',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(matricule);
                              } else if (value == 'delete') {
                                _confirmDelete(matricule);
                              }
                            },
                          ),
                        )
                      : Tooltip(
                          message: 'Matricule utilisé',
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
        childCount: provider.matricules.length,
      ),
    );
  }

  void _showCreateDialog() {
    final matriculeCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final posteCtrl = TextEditingController();
    String? selectedDept;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.badge_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Nouveau Matricule',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Matricule Field
                        _buildModernTextField(
                          controller: matriculeCtrl,
                          label: 'Matricule',
                          hint: 'Ex: 001',
                          icon: Icons.badge_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Nom Field
                        _buildModernTextField(
                          controller: nomCtrl,
                          label: 'Nom',
                          hint: 'Nom de famille',
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF10B981),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Prénom Field
                        _buildModernTextField(
                          controller: prenomCtrl,
                          label: 'Prénom',
                          hint: 'Prénom',
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF6366F1),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Poste Field
                        _buildModernTextField(
                          controller: posteCtrl,
                          label: 'Poste',
                          hint: 'Titre du poste',
                          icon: Icons.work_rounded,
                          iconColor: const Color(0xFFF59E0B),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Département Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.business_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Département *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedDept,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  hintText: 'Sélectionner un département',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0EA5E9)),
                                items: _departments.isEmpty 
                                    ? const [
                                        DropdownMenuItem(value: 'Qualité', child: Text('Qualité')),
                                        DropdownMenuItem(value: 'Logistique', child: Text('Logistique')),
                                      ]
                                    : _departments.map((d) => DropdownMenuItem(
                                        value: d.name,
                                        child: Text(d.name),
                                      )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDept = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: const Color(0xFF64748B).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0EA5E9), Color(0xFF0891B2)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0EA5E9).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      if (matriculeCtrl.text.isEmpty || 
                                          nomCtrl.text.isEmpty || 
                                          prenomCtrl.text.isEmpty || 
                                          posteCtrl.text.isEmpty || 
                                          selectedDept == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.warning_rounded, color: Colors.white),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Veuillez remplir tous les champs',
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFFF59E0B),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.pop(context);
                                      final provider = context.read<MatriculeProvider>();
                                      final success = await provider.createMatricule(
                                        matricule: matriculeCtrl.text.trim().toUpperCase(),
                                        nom: nomCtrl.text.trim(),
                                        prenom: prenomCtrl.text.trim(),
                                        poste: posteCtrl.text.trim(),
                                        department: selectedDept!,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    success ? 'Matricule créé avec succès' : provider.errorMessage ?? 'Erreur',
                                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Créer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              '$label *',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFF0EA5E9).withOpacity(0.2),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0EA5E9),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(Matricule matricule) {
    final nomCtrl = TextEditingController(text: matricule.nom);
    final prenomCtrl = TextEditingController(text: matricule.prenom);
    final posteCtrl = TextEditingController(text: matricule.poste);
    String? selectedDept = matricule.department;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${matricule.matricule}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                controller: nomCtrl,
                label: 'Nom',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: prenomCtrl,
                label: 'Prénom',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: posteCtrl,
                label: 'Poste',
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDept,
                decoration: InputDecoration(
                  labelText: 'Département',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _departments.isEmpty 
                    ? const [
                        DropdownMenuItem(value: 'Qualité', child: Text('Qualité')),
                        DropdownMenuItem(value: 'Logistique', child: Text('Logistique')),
                      ] 
                    : _departments.map((d) => DropdownMenuItem(
                        value: d.name,
                        child: Text(d.name),
                      )).toList(),
                onChanged: (value) => selectedDept = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<MatriculeProvider>();
              final success = await provider.updateMatricule(
                id: matricule.id,
                nom: nomCtrl.text.trim(),
                prenom: prenomCtrl.text.trim(),
                poste: posteCtrl.text.trim(),
                department: selectedDept,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Matricule mis à jour' : '❌ ${provider.errorMessage}'),
                    backgroundColor: success ? ModernTheme.success : ModernTheme.error,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Matricule matricule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Text('Voulez-vous vraiment supprimer le matricule ${matricule.matricule} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<MatriculeProvider>();
              final success = await provider.deleteMatricule(matricule.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Matricule supprimé' : '❌ ${provider.errorMessage}'),
                    backgroundColor: success ? ModernTheme.success : ModernTheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
