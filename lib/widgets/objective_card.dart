import 'package:flutter/material.dart';
import '../models/objective_model.dart';
import '../theme/draexlmaier_theme.dart';
import '../constants/app_constants.dart';
import 'package:intl/intl.dart';

class ObjectiveCard extends StatelessWidget {
  final Objective objective;
  final VoidCallback? onTap;
  final bool showAssignedTo;

  const ObjectiveCard({
    super.key,
    required this.objective,
    this.onTap,
    this.showAssignedTo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      objective.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  _buildPriorityChip(objective.priority),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              if (objective.description.isNotEmpty)
                Text(
                  objective.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${objective.progress}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    child: LinearProgressIndicator(
                      value: objective.progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(objective.progress),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              Row(
                children: [
                  _buildStatusChip(objective.status),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Icon(
                    Icons.calendar_today,
                    size: AppConstants.iconSizeSmall,
                    color: objective.isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(objective.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: objective.isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: objective.isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                  if (showAssignedTo) ...[
                    const Spacer(),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: DraexlmaierTheme.primaryBlue,
                      child: Text(
                        objective.assignedTo.firstname[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      objective.assignedTo.firstname,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ObjectivePriority priority) {
    Color color;
    switch (priority) {
      case ObjectivePriority.low:
        color = DraexlmaierTheme.lowPriority;
        break;
      case ObjectivePriority.medium:
        color = DraexlmaierTheme.mediumPriority;
        break;
      case ObjectivePriority.high:
        color = DraexlmaierTheme.highPriority;
        break;
      case ObjectivePriority.urgent:
        color = DraexlmaierTheme.urgentPriority;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(ObjectiveStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case ObjectiveStatus.todo:
        color = DraexlmaierTheme.todoColor;
        icon = Icons.radio_button_unchecked;
        break;
      case ObjectiveStatus.inProgress:
        color = DraexlmaierTheme.inProgressColor;
        icon = Icons.timelapse;
        break;
      case ObjectiveStatus.completed:
        color = DraexlmaierTheme.completedColor;
        icon = Icons.check_circle;
        break;
      case ObjectiveStatus.blocked:
        color = DraexlmaierTheme.blockedColor;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}
