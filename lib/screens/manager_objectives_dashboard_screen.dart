import 'package:flutter/material.dart';
import '../services/objective_service.dart';
import '../services/objective_stats_service.dart';
import '../services/error_handler.dart';
import '../models/objective_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/calendar_objectives_widget.dart';
import 'manager_objectives_screen.dart';

/// Professional Manager Objectives Dashboard
/// Complete objectives management with statistics, filters, and bulk operations
class ManagerObjectivesDashboardScreen extends StatefulWidget {
  const ManagerObjectivesDashboardScreen({super.key});

  @override
  State<ManagerObjectivesDashboardScreen> createState() => _ManagerObjectivesDashboardScreenState();
}

class _ManagerObjectivesDashboardScreenState extends State<ManagerObjectivesDashboardScreen> {
  final _objectiveService = ObjectiveService();
  final _statsService = ObjectiveStatsService();
  
  List<Objective> _objectives = [];
  List<Objective> _filteredObjectives = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPriority;
  Set<String> _selectedObjectiveIds = {};
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
      print('DEBUG: Loaded ${objectives.length} objectives');
      setState(() {
        _objectives = objectives;
        _filteredObjectives = objectives;
      });
    } catch (e) {
      print('DEBUG: Error loading objectives: $e');
      if (mounted) {
        ErrorHandler.showError(context, 'Erreur lors du chargement des objectifs: $e');
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
      print('Error loading stats: $e');
      setState(() {
        _stats = null;
      });
    }
    
    setState(() => _isLoading = false);
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredObjectives = _objectives.where((obj) {
        bool matchesSearch = _searchQuery.isEmpty ||
            obj.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            obj.assignedTo.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesStatus = _filterStatus == null || obj.status.value == _filterStatus;
        bool matchesPriority = _filterPriority == null || obj.priority.value == _filterPriority;
        
        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
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

  void _selectAll() {
    setState(() {
      if (_selectedObjectiveIds.length == _filteredObjectives.length) {
        _selectedObjectiveIds.clear();
      } else {
        _selectedObjectiveIds = _filteredObjectives.map((o) => o.id).toSet();
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedObjectiveIds.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer ${_selectedObjectiveIds.length} objectif(s)?'),
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

  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Gestion des Objectifs',
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            tooltip: _showCalendar ? 'Vue Liste' : 'Vue Calendrier',
          ),
          if (_selectedObjectiveIds.isNotEmpty && !_showCalendar)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ModernTheme.error),
              onPressed: _bulkDelete,
              tooltip: 'Supprimer sélection',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const DashboardSkeleton()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ModernTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    DashboardStatisticsSection(stats: _stats),
                    const SizedBox(height: ModernTheme.spacingL),
                    
                    if (_showCalendar)
                      CalendarObjectivesWidget(
                        objectives: _objectives,
                        onObjectiveTap: (objective) {
                          // Navigate to detail
                          Navigator.pushNamed(
                            context,
                            '/objective-detail',
                            arguments: objective.id,
                          );
                        },
                      )
                    else ...[
                      // Search and Filters
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
                      const SizedBox(height: ModernTheme.spacingM),
                      
                      // Objectives List
                      _buildObjectivesList(),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManagerObjectivesScreen(),
            ),
          );
          _loadData();
        },
        backgroundColor: ModernTheme.secondaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Créer un objectif'),
      ),
    );
  }

  Widget _buildObjectivesList() {
    if (_filteredObjectives.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Aucun objectif trouvé',
        message: 'Essayez de modifier vos filtres ou créez un nouvel objectif.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Objectifs (${_filteredObjectives.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_filteredObjectives.isNotEmpty)
              TextButton.icon(
                onPressed: _selectAll,
                icon: Icon(
                  _selectedObjectiveIds.length == _filteredObjectives.length
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                label: Text(
                  _selectedObjectiveIds.isEmpty
                      ? 'Tout sélectionner'
                      : '${_selectedObjectiveIds.length} sélectionné(s)',
                ),
              ),
          ],
        ),
        const SizedBox(height: ModernTheme.spacingS),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredObjectives.length,
          itemBuilder: (context, index) {
            final objective = _filteredObjectives[index];
            final isSelected = _selectedObjectiveIds.contains(objective.id);
            
            return DashboardObjectiveCard(
              objective: objective,
              isSelected: isSelected,
              onToggleSelection: _toggleSelection,
              onDelete: _deleteObjective,
            );
          },
        ),
      ],
    );
  }
}
