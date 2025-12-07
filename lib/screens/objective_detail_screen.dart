import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/objective_provider.dart';
import '../models/objective_model.dart';
import '../theme/draexlmaier_theme.dart';
import '../constants/app_constants.dart';

/// Écran de détail d'un objectif
class ObjectiveDetailScreen extends StatefulWidget {
  final String objectiveId;

  const ObjectiveDetailScreen({
    Key? key,
    required this.objectiveId,
  }) : super(key: key);

  @override
  State<ObjectiveDetailScreen> createState() => _ObjectiveDetailScreenState();
}

class _ObjectiveDetailScreenState extends State<ObjectiveDetailScreen> {
  final _commentController = TextEditingController();
  double _progressValue = 0;

  @override
  void initState() {
    super.initState();
    _loadObjective();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadObjective() async {
    await context.read<ObjectiveProvider>().fetchObjectiveById(widget.objectiveId);
    final objective = context.read<ObjectiveProvider>().selectedObjective;
    if (objective != null) {
      setState(() {
        _progressValue = objective.progress.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'objectif'),
        backgroundColor: DraexlmaierTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadObjective,
          ),
        ],
      ),
      body: Consumer<ObjectiveProvider>(
        builder: (context, provider, child) {
          final objective = provider.selectedObjective;

          if (provider.isLoading || objective == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et badges
                _buildHeader(objective),

                const Divider(height: 1),

                // Section progression
                _buildProgressSection(objective),

                const Divider(height: 1),

                // Dates et informations
                _buildInfoSection(objective),

                const Divider(height: 1),

                // Actions rapides
                _buildActionsSection(objective, provider),

                const Divider(height: 1),

                // Description
                _buildDescriptionSection(objective),

                // Liens
                if (objective.links.isNotEmpty) _buildLinksSection(objective),

                // Notes
                if (objective.notes != null && objective.notes!.isNotEmpty)
                  _buildNotesSection(objective),

                // Fichiers
                if (objective.files.isNotEmpty) _buildFilesSection(objective),

                const Divider(height: 1),

                // Commentaires
                _buildCommentsSection(objective, provider),

                const SizedBox(height: 80), // Espace pour le champ de saisie
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildHeader(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            objective.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                objective.status.label,
                _getStatusColor(objective.status),
                _getStatusIcon(objective.status),
              ),
              _buildBadge(
                objective.priority.label,
                _getPriorityColor(objective.priority),
                Icons.flag,
              ),
              if (objective.isOverdue)
                _buildBadge(
                  'En retard',
                  Colors.red,
                  Icons.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${objective.progress}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DraexlmaierTheme.primaryBlue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _progressValue,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_progressValue.round()}%',
            activeColor: DraexlmaierTheme.primaryBlue,
            onChanged: (value) {
              setState(() {
                _progressValue = value;
              });
            },
            onChangeEnd: (value) {
              _updateProgress(value.round());
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: Theme.of(context).textTheme.bodySmall),
              Text('50%', style: Theme.of(context).textTheme.bodySmall),
              Text('100%', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person,
            'Assigné par',
            '${objective.assignedBy.firstname} ${objective.assignedBy.lastname}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Date de début',
            DateFormat('dd MMMM yyyy', 'fr').format(objective.startDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.event,
            'Date d\'échéance',
            DateFormat('dd MMMM yyyy', 'fr').format(objective.dueDate),
            isOverdue: objective.isOverdue,
          ),
          if (objective.daysUntilDue >= 0) ...[
            const SizedBox(height: 8),
            Text(
              'Il reste ${objective.daysUntilDue} jour(s)',
              style: TextStyle(
                color: objective.daysUntilDue < 3 ? Colors.red : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isOverdue = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isOverdue ? Colors.red : Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isOverdue ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(Objective objective, ObjectiveProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: DraexlmaierTheme.backgroundGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (objective.status != ObjectiveStatus.inProgress)
                _buildActionButton(
                  'Démarrer',
                  Icons.play_arrow,
                  DraexlmaierTheme.inProgressColor,
                  () => _updateStatus(ObjectiveStatus.inProgress, provider),
                ),
              if (objective.status == ObjectiveStatus.inProgress)
                _buildActionButton(
                  'Mettre en pause',
                  Icons.pause,
                  Colors.orange,
                  () => _updateStatus(ObjectiveStatus.todo, provider),
                ),
              if (objective.status != ObjectiveStatus.completed)
                _buildActionButton(
                  'Terminer',
                  Icons.check_circle,
                  DraexlmaierTheme.completedColor,
                  () => _updateStatus(ObjectiveStatus.completed, provider),
                ),
              if (objective.status != ObjectiveStatus.blocked)
                _buildActionButton(
                  'Bloquer',
                  Icons.block,
                  DraexlmaierTheme.blockedColor,
                  () => _showBlockReasonDialog(provider),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDescriptionSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            objective.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liens',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...objective.links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    // TODO: Ouvrir le lien
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 20,
                          color: DraexlmaierTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link,
                          style: const TextStyle(
                            color: DraexlmaierTheme.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Text(
              objective.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesSection(Objective objective) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fichiers (${objective.files.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...objective.files.map((file) => Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(file.name),
                  subtitle: Text(file.sizeFormatted),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // TODO: Télécharger le fichier
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Objective objective, ObjectiveProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commentaires (${objective.comments.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          if (objective.comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Aucun commentaire'),
              ),
            )
          else
            ...objective.comments.map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ObjectiveComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: DraexlmaierTheme.primaryBlue,
            child: Text(
              comment.user.firstname[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${comment.user.firstname} ${comment.user.lastname}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: DraexlmaierTheme.primaryBlue,
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProgress(int progress) async {
    final provider = context.read<ObjectiveProvider>();
    final success = await provider.updateProgress(
      id: widget.objectiveId,
      progress: progress,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progression mise à jour')),
      );
    }
  }

  Future<void> _updateStatus(
      ObjectiveStatus status, ObjectiveProvider provider) async {
    final success = await provider.updateStatus(
      id: widget.objectiveId,
      status: status.value,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut changé en ${status.label}')),
      );
    }
  }

  Future<void> _showBlockReasonDialog(ObjectiveProvider provider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raison du blocage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Expliquez pourquoi l\'objectif est bloqué...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final success = await provider.updateStatus(
        id: widget.objectiveId,
        status: ObjectiveStatus.blocked.value,
        blockReason: result,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objectif bloqué')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final provider = context.read<ObjectiveProvider>();
    final success = await provider.addComment(
      id: widget.objectiveId,
      text: _commentController.text.trim(),
    );

    if (success) {
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commentaire ajouté')),
        );
      }
    }
  }

  Color _getStatusColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.todo:
        return DraexlmaierTheme.todoColor;
      case ObjectiveStatus.inProgress:
        return DraexlmaierTheme.inProgressColor;
      case ObjectiveStatus.completed:
        return DraexlmaierTheme.completedColor;
      case ObjectiveStatus.blocked:
        return DraexlmaierTheme.blockedColor;
    }
  }

  IconData _getStatusIcon(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.todo:
        return Icons.radio_button_unchecked;
      case ObjectiveStatus.inProgress:
        return Icons.timelapse;
      case ObjectiveStatus.completed:
        return Icons.check_circle;
      case ObjectiveStatus.blocked:
        return Icons.block;
    }
  }

  Color _getPriorityColor(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.low:
        return DraexlmaierTheme.lowPriority;
      case ObjectivePriority.medium:
        return DraexlmaierTheme.mediumPriority;
      case ObjectivePriority.high:
        return DraexlmaierTheme.highPriority;
      case ObjectivePriority.urgent:
        return DraexlmaierTheme.urgentPriority;
    }
  }
}
