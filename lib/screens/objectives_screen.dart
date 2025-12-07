import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/objective_provider.dart';
import '../models/objective_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/objective_card.dart';
import '../theme/draexlmaier_theme.dart';
import '../constants/app_constants.dart';
import 'objective_detail_screen.dart';

/// Écran des objectifs pour les employés
class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({Key? key}) : super(key: key);

  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadObjectives();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadObjectives() async {
    final provider = context.read<ObjectiveProvider>();
    await provider.fetchMyObjectives();
    await provider.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mes Objectifs',
        showLogo: true,
      ),
      body: Consumer<ObjectiveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.objectives.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error ?? 'Une erreur est survenue',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadObjectives,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadObjectives,
            child: Column(
              children: [
                // Statistiques en haut
                _buildStatsSection(provider),

                // Filtre par priorité
                _buildPriorityFilter(),

                // Onglets
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: DraexlmaierTheme.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: DraexlmaierTheme.primaryBlue,
                    tabs: [
                      Tab(
                        text: 'Tous (${provider.objectives.length})',
                      ),
                      Tab(
                        text: 'En cours (${provider.inProgressObjectives.length})',
                      ),
                      Tab(
                        text: 'À faire (${provider.todoObjectives.length})',
                      ),
                      Tab(
                        text: 'Terminés (${provider.completedObjectives.length})',
                      ),
                    ],
                  ),
                ),

                // Liste des objectifs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildObjectivesList(provider.objectives),
                      _buildObjectivesList(provider.inProgressObjectives),
                      _buildObjectivesList(provider.todoObjectives),
                      _buildObjectivesList(provider.completedObjectives),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(ObjectiveProvider provider) {
    final stats = provider.stats;
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final overdue = stats['overdue'] ?? 0;
    final avgProgress = stats['averageProgress'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: DraexlmaierTheme.backgroundGrey,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              total.toString(),
              Icons.assignment,
              DraexlmaierTheme.primaryBlue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Terminés',
              completed.toString(),
              Icons.check_circle,
              DraexlmaierTheme.successGreen,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'En retard',
              overdue.toString(),
              Icons.warning,
              DraexlmaierTheme.errorRed,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Progression',
              '$avgProgress%',
              Icons.trending_up,
              DraexlmaierTheme.infoBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPriorityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Priorité: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            _buildPriorityChip('Toutes', null),
            const SizedBox(width: 8),
            _buildPriorityChip('Basse', AppConstants.priorityLow),
            const SizedBox(width: 8),
            _buildPriorityChip('Moyenne', AppConstants.priorityMedium),
            const SizedBox(width: 8),
            _buildPriorityChip('Haute', AppConstants.priorityHigh),
            const SizedBox(width: 8),
            _buildPriorityChip('Urgente', AppConstants.priorityUrgent),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, String? priority) {
    final isSelected = _selectedPriority == priority;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPriority = selected ? priority : null;
        });
        context.read<ObjectiveProvider>().fetchMyObjectives(
              priority: _selectedPriority,
            );
      },
      selectedColor: DraexlmaierTheme.primaryBlue.withOpacity(0.2),
      checkmarkColor: DraexlmaierTheme.primaryBlue,
    );
  }

  Widget _buildObjectivesList(List<Objective> objectives) {
    if (objectives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun objectif',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas d\'objectifs dans cette catégorie',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      itemCount: objectives.length,
      itemBuilder: (context, index) {
        final objective = objectives[index];
        return ObjectiveCard(
          objective: objective,
          onTap: () => _navigateToDetail(objective),
        );
      },
    );
  }

  void _navigateToDetail(Objective objective) {
    context.read<ObjectiveProvider>().selectObjective(objective);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectiveDetailScreen(objectiveId: objective.id),
      ),
    );
  }
}
