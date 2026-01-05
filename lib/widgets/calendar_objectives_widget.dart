import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/objective_model.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';

class CalendarObjectivesWidget extends StatefulWidget {
  final List<Objective> objectives;
  final Function(Objective) onObjectiveTap;

  const CalendarObjectivesWidget({
    super.key,
    required this.objectives,
    required this.onObjectiveTap,
  });

  @override
  State<CalendarObjectivesWidget> createState() => _CalendarObjectivesWidgetState();
}

class _CalendarObjectivesWidgetState extends State<CalendarObjectivesWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Objective>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _groupObjectivesByDate();
  }

  @override
  void didUpdateWidget(covariant CalendarObjectivesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _groupObjectivesByDate();
  }

  void _groupObjectivesByDate() {
    _events = {};
    for (var objective in widget.objectives) {
      final date = DateTime(
        objective.dueDate.year,
        objective.dueDate.month,
        objective.dueDate.day,
      );
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]!.add(objective);
    }
  }

  List<Objective> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedObjectives = _getEventsForDay(_selectedDay!);

    return Column(
      children: [
        ModernCard(
          child: TableCalendar<Objective>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: ModernTheme.primaryBlue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: ModernTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: ModernTheme.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ModernTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: ModernTheme.spacingM),
        if (selectedObjectives.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ModernTheme.spacingM),
            child: Row(
              children: [
                Text(
                  'Échéances du ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ModernTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedObjectives.length}',
                    style: const TextStyle(
                      color: ModernTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ModernTheme.spacingS),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedObjectives.length,
            itemBuilder: (context, index) {
              final objective = selectedObjectives[index];
              return ModernCard(
                onTap: () => widget.onObjectiveTap(objective),
                margin: const EdgeInsets.symmetric(
                  horizontal: ModernTheme.spacingM,
                  vertical: 4,
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(objective.status),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objective.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Assigné à: ${objective.assignedTo.fullName}',
                            style: const TextStyle(
                              color: ModernTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: objective.priority.label,
                      color: _getPriorityColor(objective.priority),
                    ),
                  ],
                ),
              );
            },
          ),
        ] else
          const EmptyState(
            icon: Icons.event_available,
            title: 'Aucune échéance',
            message: 'Aucun objectif prévu pour cette date.',
          ),
      ],
    );
  }

  Color _getStatusColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.todo: return ModernTheme.info;
      case ObjectiveStatus.inProgress: return ModernTheme.warning;
      case ObjectiveStatus.completed: return ModernTheme.success;
      case ObjectiveStatus.blocked: return ModernTheme.error;
    }
  }

  Color _getPriorityColor(ObjectivePriority priority) {
    switch (priority) {
      case ObjectivePriority.urgent: return ModernTheme.error;
      case ObjectivePriority.high: return ModernTheme.warning;
      case ObjectivePriority.medium: return ModernTheme.info;
      case ObjectivePriority.low: return ModernTheme.textTertiary;
    }
  }
}
