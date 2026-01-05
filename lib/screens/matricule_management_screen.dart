import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matricule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/matricule_model.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Matricule'),
        backgroundColor: ModernTheme.primaryBlue,
        elevation: 4,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: ModernTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Gestion des Matricules',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernTheme.primaryBlue,
                ModernTheme.primaryBlue.withBlue(180),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.badge_outlined,
                  size: 150,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadData,
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildStats(MatriculeStats stats) {
    return Row(
      children: [
        Expanded(
          child: ModernStatCard(
            title: 'Total',
            value: stats.total.toString(),
            icon: Icons.badge_outlined,
            gradient: const LinearGradient(colors: [Color(0xFF003DA5), Color(0xFF00A9E0)]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernStatCard(
            title: 'Utilisés',
            value: stats.used.toString(),
            icon: Icons.check_circle_outline,
            gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernStatCard(
            title: 'Libres',
            value: stats.available.toString(),
            icon: Icons.hourglass_empty,
            gradient: const LinearGradient(colors: [Color(0xFFED6C02), Color(0xFFFFB74D)]),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(MatriculeProvider provider) {
    final departments = ['Qualité', 'Logistique', 'MM Shift A', 'MM Shift B', 'SZB Shift A', 'SZB Shift B'];
    
    return Column(
      children: [
        ModernTextField(
          controller: _searchController,
          label: '',
          hint: 'Rechercher un matricule ou un nom...',
          prefixIcon: Icons.search,
          onChanged: (val) {
            provider.setFilters(
              status: _statusFilter,
              department: _departmentFilter,
              search: val,
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    hint: const Text('Statut', style: TextStyle(fontSize: 14, color: ModernTheme.textSecondary)),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: ModernTheme.primaryBlue),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tous les statuts')),
                      DropdownMenuItem(value: 'available', child: Text('Disponibles')),
                      DropdownMenuItem(value: 'used', child: Text('Utilisés')),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _departmentFilter,
                    hint: const Text('Département', style: TextStyle(fontSize: 14, color: ModernTheme.textSecondary)),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: ModernTheme.primaryBlue),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: ModernTheme.spacingM, vertical: 4),
            child: ModernCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  width: 50,
                  height: 50,
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
                        color: (matricule.isUsed ? Colors.green : Colors.orange).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      matricule.matricule.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${matricule.matricule} • ${matricule.nomComplet}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('${matricule.poste} | ${matricule.department}', 
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    StatusBadge(
                      label: matricule.statut.toUpperCase(),
                      color: matricule.isUsed ? ModernTheme.success : ModernTheme.warning,
                      icon: matricule.isUsed ? Icons.check_circle : Icons.hourglass_empty,
                    ),
                  ],
                ),
                trailing: !matricule.isUsed
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: ModernTheme.textTertiary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20, color: ModernTheme.primaryBlue),
                                SizedBox(width: 12),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
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
                      )
                    : Tooltip(
                        message: 'Matricule utilisé',
                        child: Icon(Icons.lock_outline, color: Colors.grey.withOpacity(0.5), size: 20),
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
      builder: (context) => AlertDialog(
        title: const Text('Nouveau Matricule'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                controller: matriculeCtrl,
                label: 'Matricule *',
                hint: 'Ex: 001',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: nomCtrl,
                label: 'Nom *',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: prenomCtrl,
                label: 'Prénom *',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                controller: posteCtrl,
                label: 'Poste *',
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDept,
                decoration: InputDecoration(
                  labelText: 'Département *',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: const [
                  DropdownMenuItem(value: 'Qualité', child: Text('Qualité')),
                  DropdownMenuItem(value: 'Logistique', child: Text('Logistique')),
                  DropdownMenuItem(value: 'MM Shift A', child: Text('MM Shift A')),
                  DropdownMenuItem(value: 'MM Shift B', child: Text('MM Shift B')),
                  DropdownMenuItem(value: 'SZB Shift A', child: Text('SZB Shift A')),
                  DropdownMenuItem(value: 'SZB Shift B', child: Text('SZB Shift B')),
                ],
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
              if (matriculeCtrl.text.isEmpty || nomCtrl.text.isEmpty || prenomCtrl.text.isEmpty || posteCtrl.text.isEmpty || selectedDept == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
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
                    content: Text(success ? '✅ Matricule créé avec succès' : '❌ ${provider.errorMessage}'),
                    backgroundColor: success ? ModernTheme.success : ModernTheme.error,
                  ),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
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
                items: const [
                  DropdownMenuItem(value: 'Qualité', child: Text('Qualité')),
                  DropdownMenuItem(value: 'Logistique', child: Text('Logistique')),
                  DropdownMenuItem(value: 'MM Shift A', child: Text('MM Shift A')),
                  DropdownMenuItem(value: 'MM Shift B', child: Text('MM Shift B')),
                  DropdownMenuItem(value: 'SZB Shift A', child: Text('SZB Shift A')),
                  DropdownMenuItem(value: 'SZB Shift B', child: Text('SZB Shift B')),
                ],
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
