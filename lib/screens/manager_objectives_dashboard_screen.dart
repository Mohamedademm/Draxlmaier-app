import 'package:flutter/material.dart';
import '../services/objective_service.dart';
import '../services/objective_stats_service.dart';
import '../services/error_handler.dart';
import '../models/objective_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import 'manager_objectives_screen.dart';

/// Professional Manager Objectives Dashboard
/// Complete objectives management with statistics, filters, and bulk operations
class ManagerObjectivesDashboardScreen extends StatefulWidget {
  const ManagerObjectivesDashboardScreen({super.key});

  @override
  State<ManagerObjectivesDashboardScreen> createState() =>
      _ManagerObjectivesDashboardScreenState();
}

class _ManagerObjectivesDashboardScreenState
    extends State<ManagerObjectivesDashboardScreen> {
  final _objectiveService = ObjectiveService();
  final _statsService = ObjectiveStatsService();

  List<Objective> _objectives = [];
  List<Objective> _filteredObjectives = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPriority;
  final Set<String> _selectedObjectiveIds = {};
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final objectives = await _objectiveService.getTeamObjectives();
      debugPrint('DEBUG: Loaded ${objectives.length} objectives');
      
      setState(() {
        _objectives = objectives;
        _filteredObjectives = objectives;
      });
    } catch (e) {
      debugPrint('DEBUG: Error loading objectives: $e');
      if (mounted) {
        ErrorHandler.showError(
            context, 'Erreur lors du chargement des objectifs: $e');
      }
      setState(() {
        _objectives = [];
        _filteredObjectives = [];
      });
    }

    try {
      final stats = await _statsService.getStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      // Stats failure shouldn't block the UI, just log it
      debugPrint('Error loading stats: $e');
      setState(() {
        _stats = null;
      });
    }

    setState(() => _isLoading = false);
    _applyFilters();
  }

  /// Smart deduplication of department objectives
  /// Groups by department and keeps only one entry per unique department objective
  List<Objective> _deduplicateDepartmentObjectives(List<Objective> objectives) {
    final List<Objective> result = [];
    final Set<String> seenDepartmentObjectives = {};
    
    for (var objective in objectives) {
      if (objective.departmentId != null && objective.departmentId!.isNotEmpty) {
        // Create unique signature for department objectives
        final signature = '${objective.title}_${objective.departmentId}_'
            '${objective.description}_${objective.priority.value}_'
            '${objective.dueDate.millisecondsSinceEpoch}';
        
        if (!seenDepartmentObjectives.contains(signature)) {
          seenDepartmentObjectives.add(signature);
          result.add(objective);
        }
      } else {
        // Individual objectives always pass through
        result.add(objective);
      }
    }
    
    return result;
  }

  /// Get statistics breakdown
  Map<String, dynamic> _getObjectiveStats(List<Objective> objectives) {
    final departmentCount = objectives.where((o) => 
        o.departmentId != null && o.departmentId!.isNotEmpty).length;
    final individualCount = objectives.length - departmentCount;
    
    return {
      'total': objectives.length,
      'department': departmentCount,
      'individual': individualCount,
      'completed': objectives.where((o) => o.status.value == 'completed').length,
      'inProgress': objectives.where((o) => o.status.value == 'in-progress').length,
      'notStarted': objectives.where((o) => o.status.value == 'not-started').length,
    };
  }

  void _applyFilters() {
    setState(() {
      // FIRST: Deduplicate department objectives
      var dedupedObjectives = _deduplicateDepartmentObjectives(_objectives);
      
      // SECOND: Apply search and filters
      _filteredObjectives = dedupedObjectives.where((obj) {
        bool matchesSearch = _searchQuery.isEmpty ||
            obj.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            obj.assignedTo.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            obj.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (obj.departmentId != null && obj.departmentId!.toLowerCase().contains(_searchQuery.toLowerCase()));

        bool matchesStatus =
            _filterStatus == null || obj.status.value == _filterStatus;
        bool matchesPriority =
            _filterPriority == null || obj.priority.value == _filterPriority;

        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
      
      // THIRD: Smart sorting - department objectives first, then by priority and date
      _filteredObjectives.sort((a, b) {
        final aDept = a.departmentId != null && a.departmentId!.isNotEmpty;
        final bDept = b.departmentId != null && b.departmentId!.isNotEmpty;
        
        // Department objectives always come first
        if (aDept && !bDept) return -1;
        if (!aDept && bDept) return 1;
        
        // Within same type, sort by priority (high > medium > low)
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        final aPriority = priorityOrder[a.priority.value] ?? 3;
        final bPriority = priorityOrder[b.priority.value] ?? 3;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // Finally sort by due date (soonest first)
        return a.dueDate.compareTo(b.dueDate);
      });
    });
  }

  void _toggleSelection(String objectiveId) {
    setState(() {
      if (_selectedObjectiveIds.contains(objectiveId)) {
        _selectedObjectiveIds.remove(objectiveId);
      } else {
        _selectedObjectiveIds.add(objectiveId);
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedObjectiveIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous supprimer ${_selectedObjectiveIds.length} objectif(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: ModernTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _statsService.bulkDelete(_selectedObjectiveIds.toList());
        setState(() => _selectedObjectiveIds.clear());
        await _loadData();
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Objectifs supprimés avec succès');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, 'Erreur lors de la suppression: $e');
        }
      }
    }
  }

  Future<void> _deleteObjective(String id) async {
    try {
      await _objectiveService.deleteObjective(id);
      await _loadData();
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Objectif supprimé');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Erreur lors de la suppression: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract stats
    final total = int.tryParse(_stats?['total']?.toString() ?? '0') ?? 0;
    final todo = (_stats?['byStatus']?['todo'] ?? 0) as int;
    final inProgress = (_stats?['byStatus']?['in_progress'] ?? 0) as int;
    final completed = (_stats?['byStatus']?['completed'] ?? 0) as int;
    final blocked = (_stats?['byStatus']?['blocked'] ?? 0) as int;
    final overdue = (_stats?['overdue'] ?? 0) as int;

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
              child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gestion des Objectifs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            ),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chargement des objectifs...',
                    style: TextStyle(
                      color: Color(0xFF0EA5E9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF0EA5E9),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. STATS CHARTS SECTION
                    if (_stats != null) ...[
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
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
                                        child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Vue d\'ensemble',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0EA5E9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                            
                            // Modern Summary Cards with statistics
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernSummaryCard(
                                    'Total',
                                    total.toString(),
                                    Icons.assignment_rounded,
                                    const LinearGradient(
                                      colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernSummaryCard(
                                    'Départements',
                                    _getObjectiveStats(_filteredObjectives)['department'].toString(),
                                    Icons.business_rounded,
                                    const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernSummaryCard(
                                    'Individuels',
                                    _getObjectiveStats(_filteredObjectives)['individual'].toString(),
                                    Icons.person_rounded,
                                    const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernSummaryCard(
                                    'Complétés',
                                    _getObjectiveStats(_filteredObjectives)['completed'].toString(),
                                    Icons.check_circle_rounded,
                                    const LinearGradient(
                                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernSummaryCard(
                                    'En cours',
                                    _getObjectiveStats(_filteredObjectives)['inProgress'].toString(),
                                    Icons.pending_rounded,
                                    const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                                    ),
                                  ),
                                ),
                                if (overdue > 0) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModernSummaryCard(
                                      'En retard',
                                      overdue.toString(),
                                      Icons.warning_rounded,
                                      const LinearGradient(
                                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                      
                      // Status Distribution Chart
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withOpacity(0.1),
                              blurRadius: 20,
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Répartition par statut',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0EA5E9),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _buildAnimatedStatusBar('À faire', todo, Colors.orange, total),
                            const SizedBox(height: 18),
                            _buildAnimatedStatusBar('En cours', inProgress, Colors.purple, total),
                            const SizedBox(height: 18),
                            _buildAnimatedStatusBar('Terminé', completed, Colors.green, total),
                            const SizedBox(height: 18),
                            _buildAnimatedStatusBar('Bloqué', blocked, Colors.red, total),
                          ],
                        ),
                      ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 2. FILTERS
                    DashboardFiltersSection(
                      searchController: _searchController,
                      filterStatus: _filterStatus,
                      filterPriority: _filterPriority,
                      onStatusChanged: (value) {
                        setState(() => _filterStatus = value);
                        _applyFilters();
                      },
                      onPriorityChanged: (value) {
                        setState(() => _filterPriority = value);
                        _applyFilters();
                      },
                      onClearFilters: () {
                        setState(() {
                          _filterStatus = null;
                          _filterPriority = null;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. FILTERS SECTION WITH VISUAL CHIPS
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.08),
                            blurRadius: 20,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Filtres',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const Spacer(),
                              if (_filterStatus != null || _filterPriority != null)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _filterStatus = null;
                                      _filterPriority = null;
                                    });
                                    _applyFilters();
                                  },
                                  icon: const Icon(Icons.clear_all, size: 18),
                                  label: const Text('Réinitialiser'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Non démarré',
                                'not-started',
                                Icons.radio_button_unchecked,
                                const Color(0xFF94A3B8),
                                _filterStatus == 'not-started',
                              ),
                              _buildFilterChip(
                                'En cours',
                                'in-progress',
                                Icons.pending_rounded,
                                const Color(0xFFF59E0B),
                                _filterStatus == 'in-progress',
                              ),
                              _buildFilterChip(
                                'Complété',
                                'completed',
                                Icons.check_circle_rounded,
                                const Color(0xFF10B981),
                                _filterStatus == 'completed',
                              ),
                              _buildFilterChip(
                                'Bloqué',
                                'blocked',
                                Icons.block_rounded,
                                const Color(0xFFEF4444),
                                _filterStatus == 'blocked',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Priorité',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Haute',
                                'high',
                                Icons.priority_high_rounded,
                                const Color(0xFFEF4444),
                                _filterPriority == 'high',
                              ),
                              _buildFilterChip(
                                'Moyenne',
                                'medium',
                                Icons.drag_handle_rounded,
                                const Color(0xFFF59E0B),
                                _filterPriority == 'medium',
                              ),
                              _buildFilterChip(
                                'Basse',
                                'low',
                                Icons.arrow_downward_rounded,
                                const Color(0xFF10B981),
                                _filterPriority == 'low',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 4. BULK ACTIONS
                    if (_selectedObjectiveIds.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ModernTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: ModernTheme.primaryBlue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedObjectiveIds.length} sélectionné(s)',
                              style: const TextStyle(
                                  color: ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _bulkDelete,
                              tooltip: 'Supprimer la sélection',
                            ),
                          ],
                        ),
                      ),

                    // 5. LIST
                    _buildObjectivesList(isSliver: false),
                  ],
                ),
              ),
            ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 900),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerObjectivesScreen(),
                  ),
                );
                _loadData();
              },
              backgroundColor: const Color(0xFF0EA5E9),
              elevation: 8,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
              label: const Text(
                'Créer un objectif',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStatusBar(String label, int value, Color color, int total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Text(
                '$value (${percentage.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: percentage / 100),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 14,
                    width: MediaQuery.of(context).size.width * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  /// Modern summary card with gradient styling
  Widget _buildModernSummaryCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withOpacity(0.9),
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build a modern filter chip
  Widget _buildFilterChip(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          if (value.contains('-')) {
            // Status filter
            _filterStatus = isSelected ? null : value;
          } else {
            // Priority filter
            _filterPriority = isSelected ? null : value;
          }
        });
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesList({bool isSliver = false}) {
    if (_filteredObjectives.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: 'Aucun objectif trouvé',
          message:
              'Essayez de modifier vos filtres ou créez un nouvel objectif.',
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _filteredObjectives.length,
      itemBuilder: (context, index) {
        final objective = _filteredObjectives[index];
        final isSelected = _selectedObjectiveIds.contains(objective.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DashboardObjectiveCard(
            objective: objective,
            isSelected: isSelected,
            onToggleSelection: _toggleSelection,
            onDelete: _deleteObjective,
          ),
        );
      },
    );
  }
}
/* Original Layout commented out for safe revert */
