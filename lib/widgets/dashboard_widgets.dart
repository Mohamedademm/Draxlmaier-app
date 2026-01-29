import 'package:flutter/material.dart';
import '../models/objective_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/chart_widgets.dart';

class DashboardStatisticsSection extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const DashboardStatisticsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox();

    final todo = stats!['byStatus']?['todo'] ?? 0;
    final inProgress = stats!['byStatus']?['in_progress'] ?? 0;
    final completed = stats!['byStatus']?['completed'] ?? 0;
    final blocked = stats!['byStatus']?['blocked'] ?? 0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
              ),
        ),
        const SizedBox(height: ModernTheme.spacingM),
        
        // Charts Row (Responsive)
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Répartition par Statut',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ObjectiveStatusPieChart(
                            todo: todo,
                            inProgress: inProgress,
                            completed: completed,
                            blocked: blocked,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activité Hebdomadaire',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const WeeklyProgressBarChart(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Répartition par Statut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ObjectiveStatusPieChart(
                          todo: todo,
                          inProgress: inProgress,
                          completed: completed,
                          blocked: blocked,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activité Hebdomadaire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const WeeklyProgressBarChart(),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: ModernTheme.spacingM),
        
        // Key Metrics Row
        // Using Row + Expanded instead of GridView to avoid overflow and manage height flexibility
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                title: 'Total',
                value: '${stats!['total'] ?? 0}',
                icon: Icons.assignment,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
              ),
            ),
             const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: ModernStatCard(
                title: 'En Retard',
                value: '${stats!['overdue'] ?? 0}',
                icon: Icons.warning,
                gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardFiltersSection extends StatelessWidget {
  final TextEditingController searchController;
  final String? filterStatus;
  final String? filterPriority;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  final VoidCallback onClearFilters;

  const DashboardFiltersSection({
    super.key,
    required this.searchController,
    required this.filterStatus,
    required this.filterPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernTextField(
          controller: searchController,
          label: 'Recherche',
          hint: 'Rechercher un objectif...',
          prefixIcon: Icons.search,
        ),
        const SizedBox(height: ModernTheme.spacingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Statut',
                value: filterStatus,
                items: const [
                  {'value': 'todo', 'label': 'À faire'},
                  {'value': 'in_progress', 'label': 'En cours'},
                  {'value': 'completed', 'label': 'Terminé'},
                  {'value': 'blocked', 'label': 'Bloqué'},
                ],
                onChanged: onStatusChanged,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Priorité',
                value: filterPriority,
                items: const [
                  {'value': 'low', 'label': 'Basse'},
                  {'value': 'medium', 'label': 'Moyenne'},
                  {'value': 'high', 'label': 'Haute'},
                  {'value': 'urgent', 'label': 'Urgente'},
                ],
                onChanged: onPriorityChanged,
              ),
              const SizedBox(width: 8),
              if (filterStatus != null || filterPriority != null)
                ActionChip(
                  label: const Text('Réinitialiser'),
                  avatar: const Icon(Icons.clear, size: 18),
                  onPressed: onClearFilters,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return PopupMenuButton<String>(
          color: isDark ? ModernTheme.darkSurface : ModernTheme.surface,
          itemBuilder: (context) => [
            ...items.map((item) => PopupMenuItem(
              value: item['value'],
              child: Text(item['label']!, style: TextStyle(color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary)),
            )),
            PopupMenuItem(
              value: null,
              child: Text('Tous', style: TextStyle(color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary)),
            ),
          ],
          onSelected: onChanged,
          child: Chip(
            label: Text(
              value == null ? label : items.firstWhere((i) => i['value'] == value)['label']!,
              style: TextStyle(color: value != null ? ModernTheme.primaryBlue : (isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary)),
            ),
            avatar: Icon(Icons.filter_list, size: 18, color: value != null ? ModernTheme.primaryBlue : (isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary)),
            backgroundColor: value != null ? ModernTheme.primaryBlue.withOpacity(0.1) : (isDark ? ModernTheme.darkSurface : ModernTheme.surface),
            side: BorderSide(color: value != null ? ModernTheme.primaryBlue : (isDark ? Colors.white24 : Colors.grey.shade300)),
          ),
        );
      }
    );
  }
}

class DashboardObjectiveCard extends StatelessWidget {
  final Objective objective;
  final bool isSelected;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<String> onDelete;

  const DashboardObjectiveCard({
    super.key,
    required this.objective,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if context is dark for correct color choice
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernCard(
      onTap: () => onToggleSelection(objective.id),
      color: isSelected 
          ? ModernTheme.primaryBlue.withOpacity(0.05) 
          : (isDark ? ModernTheme.darkSurface : ModernTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection(objective.id),
                activeColor: ModernTheme.primaryBlue,
                side: BorderSide(color: isDark ? Colors.white54 : Colors.grey, width: 2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objective.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? ModernTheme.darkTextPrimary : ModernTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Show department icon and name if it's a department objective
                        if (objective.departmentId != null && objective.departmentId!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.business_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Département: ${objective.departmentId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Show assigned user for individual objectives
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Assigné à: ${objective.assignedTo.fullName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary),
                color: isDark ? ModernTheme.darkSurface : ModernTheme.surface,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: ModernTheme.error),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: ModernTheme.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete(objective.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.spacingM),
          Row(
            children: [
              StatusBadge(
                label: objective.priority.label,
                color: _getPriorityColor(objective.priority),
                icon: Icons.flag,
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: objective.status.label,
                color: _getStatusColor(objective.status),
                icon: Icons.info_outline,
              ),
              const Spacer(),
              Text(
                '${objective.dueDate.day}/${objective.dueDate.month}/${objective.dueDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: objective.isOverdue ? ModernTheme.error : (isDark ? ModernTheme.darkTextTertiary : ModernTheme.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.spacingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: objective.progress / 100,
              backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                objective.progress == 100 ? ModernTheme.success : ModernTheme.primaryBlue,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.urgent: return ModernTheme.error;
      case ObjectivePriority.high: return ModernTheme.warning;
      case ObjectivePriority.medium: return ModernTheme.info;
      case ObjectivePriority.low: return ModernTheme.textTertiary;
    }
  }

  Color _getStatusColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.todo: return ModernTheme.info;
      case ObjectiveStatus.inProgress: return ModernTheme.warning;
      case ObjectiveStatus.completed: return ModernTheme.success;
      case ObjectiveStatus.blocked: return ModernTheme.error;
    }
  }
}
