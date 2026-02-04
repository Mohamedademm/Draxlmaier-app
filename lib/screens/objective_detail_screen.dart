
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/objective_provider.dart';
import '../models/objective_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/skeleton_loader.dart';

class ObjectiveDetailScreen extends StatefulWidget {
  final String objectiveId;

  const ObjectiveDetailScreen({
    super.key,
    required this.objectiveId,
  });

  @override
  State<ObjectiveDetailScreen> createState() => _ObjectiveDetailScreenState();
}

class _ObjectiveDetailScreenState extends State<ObjectiveDetailScreen> {
  final _commentController = TextEditingController();
  double _progressValue = 0;
  Objective? _objective;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadObjective();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadObjective() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<ObjectiveProvider>();
      await provider.fetchObjectiveById(widget.objectiveId);
      
      if (mounted) {
        setState(() {
          _objective = provider.selectedObjective;
          if (_objective != null) {
            _progressValue = _objective!.progress.toDouble();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading objective: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Détails de l\'objectif',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ModernTheme.textPrimary),
            onPressed: _loadObjective,
          ),
        ],
      ),
      body: _isLoading
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SkeletonObjectiveCard(),
                  SizedBox(height: 16),
                  SkeletonCard(height: 150),
                  SizedBox(height: 16),
                  SkeletonCard(height: 200),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: ModernTheme.error),
                      const SizedBox(height: 16),
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadObjective,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _objective == null
                  ? const Center(child: Text('Objectif non trouvé'))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(ModernTheme.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderCard(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildProgressCard(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildInfoGrid(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildSubTasksSection(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                ModernCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: ModernTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _objective!.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: ModernTheme.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildActionsCard(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildFilesSection(_objective!),
                                const SizedBox(height: ModernTheme.spacingM),

                                _buildCommentsSection(_objective!),
                              ],
                            ),
                          ),
                        ),
                        _buildCommentInputArea(),
                      ],
                    ),
    );
  }

  Widget _buildHeaderCard(Objective objective) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            objective.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ModernTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                label: objective.status.label,
                color: _getStatusColor(objective.status),
                icon: _getStatusIcon(objective.status),
              ),
              StatusBadge(
                label: objective.priority.label,
                color: _getPriorityColor(objective.priority),
                icon: Icons.flag,
              ),
              if (objective.isOverdue)
                const StatusBadge(
                  label: 'En retard',
                  color: ModernTheme.error,
                  icon: Icons.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Objective objective) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progression',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
              ),
              Text(
                '${objective.progress}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ModernTheme.primaryBlue,
              inactiveTrackColor: ModernTheme.surfaceVariant,
              thumbColor: ModernTheme.primaryBlue,
              overlayColor: ModernTheme.primaryBlue.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _progressValue,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${_progressValue.round()}%',
              onChanged: (value) {
                setState(() => _progressValue = value);
              },
              onChangeEnd: (value) {
                _updateProgress(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Objective objective) {
    return Row(
      children: [
        Expanded(
          child: ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Début',
                  style: TextStyle(fontSize: 12, color: ModernTheme.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy', 'fr').format(objective.startDate),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: ModernTheme.spacingM),
        Expanded(
          child: ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Échéance',
                  style: TextStyle(fontSize: 12, color: ModernTheme.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy', 'fr').format(objective.dueDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: objective.isOverdue ? ModernTheme.error : ModernTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(Objective objective) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ModernTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (objective.status != ObjectiveStatus.inProgress)
                _buildActionButton(
                  'Démarrer',
                  Icons.play_arrow,
                  ModernTheme.warning,
                  () => _updateStatus(ObjectiveStatus.inProgress),
                ),
              if (objective.status == ObjectiveStatus.inProgress)
                _buildActionButton(
                  'Pause',
                  Icons.pause,
                  Colors.orange,
                  () => _updateStatus(ObjectiveStatus.todo),
                ),
              if (objective.status != ObjectiveStatus.completed)
                _buildActionButton(
                  'Terminer',
                  Icons.check_circle,
                  ModernTheme.success,
                  () => _updateStatus(ObjectiveStatus.completed),
                ),
              if (objective.status != ObjectiveStatus.blocked)
                _buildActionButton(
                  'Bloquer',
                  Icons.block,
                  ModernTheme.error,
                  () => _showBlockReasonDialog(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTasksSection(Objective objective) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-tâches (${objective.subTasks.where((s) => s.isCompleted).length}/${objective.subTasks.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: ModernTheme.primaryBlue),
                onPressed: () => _showAddSubTaskDialog(),
                tooltip: 'Ajouter une sous-tâche',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (objective.subTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Aucune sous-tâche pour le moment.',
                style: TextStyle(color: ModernTheme.textSecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: objective.subTasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final subTask = objective.subTasks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: subTask.isCompleted,
                    activeColor: ModernTheme.success,
                    onChanged: (value) {
                      context.read<ObjectiveProvider>().toggleSubTask(
                        objectiveId: objective.id,
                        subTaskId: subTask.id,
                      );
                      _loadObjective();
                    },
                  ),
                  title: Text(
                    subTask.title,
                    style: TextStyle(
                      decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
                      color: subTask.isCompleted ? ModernTheme.textTertiary : ModernTheme.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: ModernTheme.error, size: 20),
                    onPressed: () {
                      context.read<ObjectiveProvider>().deleteSubTask(
                        objectiveId: objective.id,
                        subTaskId: subTask.id,
                      );
                      _loadObjective();
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showAddSubTaskDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle sous-tâche'),
        content: ModernTextField(
          controller: controller,
          label: 'Titre',
          hint: 'Ex: Préparer le rapport...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final provider = context.read<ObjectiveProvider>();
      final success = await provider.addSubTask(
        id: widget.objectiveId,
        title: result,
      );

      if (success && mounted) {
        _loadObjective();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sous-tâche ajoutée'),
            backgroundColor: ModernTheme.success,
          ),
        );
      }
    }
  }

  Widget _buildFilesSection(Objective objective) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 20, color: ModernTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Fichiers (${objective.files.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: ModernTheme.primaryBlue),
                onPressed: _pickAndUploadFile,
                tooltip: 'Ajouter un fichier',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (objective.files.isEmpty)
          const EmptyState(
            icon: Icons.folder_open,
            title: 'Aucun fichier',
            message: 'Ajoutez des documents utiles à cet objectif.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: objective.files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = objective.files[index];
              return ModernCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.insert_drive_file, color: ModernTheme.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            file.sizeFormatted,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ModernTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: ModernTheme.textSecondary),
                      onPressed: () {
                        // TODO: Download logic
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _pickAndUploadFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('L\'upload de fichiers est temporairement désactivé sur le Web.')),
    );
  }

  Widget _buildCommentsSection(Objective objective) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.comment_outlined, size: 20, color: ModernTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Commentaires (${objective.comments.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (objective.comments.isEmpty)
          const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Aucun commentaire',
            message: 'Soyez le premier à commenter cet objectif.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: objective.comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comment = objective.comments[index];
              return ModernCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: ModernTheme.primaryBlue,
                          child: Text(
                            comment.user.firstname[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${comment.user.firstname} ${comment.user.lastname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: ModernTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ModernTheme.textSecondary,
                        height: 1.4,
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

  Widget _buildCommentInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: _commentController,
                label: '',
                hint: 'Écrire un commentaire...',
                maxLines: null,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _addComment,
              ),
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
        const SnackBar(
          content: Text('Progression mise à jour'),
          backgroundColor: ModernTheme.success,
        ),
      );
    }
  }

  Future<void> _updateStatus(ObjectiveStatus status) async {
    final provider = context.read<ObjectiveProvider>();
    final success = await provider.updateStatus(
      id: widget.objectiveId,
      status: status.value,
    );

    if (success && mounted) {
      _loadObjective();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut changé en ${status.label}'),
          backgroundColor: ModernTheme.success,
        ),
      );
    }
  }

  Future<void> _showBlockReasonDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raison du blocage'),
        content: ModernTextField(
          controller: controller,
          label: 'Raison',
          hint: 'Expliquez pourquoi...',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: ModernTheme.error),
            child: const Text('Bloquer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final provider = context.read<ObjectiveProvider>();
      final success = await provider.updateStatus(
        id: widget.objectiveId,
        status: ObjectiveStatus.blocked.value,
        blockReason: result,
      );

      if (success && mounted) {
        _loadObjective();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objectif bloqué'),
            backgroundColor: ModernTheme.error,
          ),
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

  IconData _getStatusIcon(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.todo: return Icons.radio_button_unchecked;
      case ObjectiveStatus.inProgress: return Icons.timelapse;
      case ObjectiveStatus.completed: return Icons.check_circle;
      case ObjectiveStatus.blocked: return Icons.block;
    }
  }

  Color _getPriorityColor(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.low: return ModernTheme.textTertiary;
      case ObjectivePriority.medium: return ModernTheme.info;
      case ObjectivePriority.high: return ModernTheme.warning;
      case ObjectivePriority.urgent: return ModernTheme.error;
    }
  }
}
