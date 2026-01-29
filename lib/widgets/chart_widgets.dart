import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

/// Pie Chart showing Objective Status Distribution
class ObjectiveStatusPieChart extends StatefulWidget {
  final int todo;
  final int inProgress;
  final int completed;
  final int blocked;

  const ObjectiveStatusPieChart({
    super.key,
    required this.todo,
    required this.inProgress,
    required this.completed,
    required this.blocked,
  });

  @override
  State<ObjectiveStatusPieChart> createState() => _ObjectiveStatusPieChartState();
}

class _ObjectiveStatusPieChartState extends State<ObjectiveStatusPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.todo + widget.inProgress + widget.completed + widget.blocked;
    if (total == 0) {
      return const Center(child: Text('Aucune donnée'));
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Indicator(color: ModernTheme.info, text: 'À faire', isSquare: true),
              SizedBox(height: 4),
              _Indicator(color: ModernTheme.warning, text: 'En cours', isSquare: true),
              SizedBox(height: 4),
              _Indicator(color: ModernTheme.success, text: 'Terminé', isSquare: true),
              SizedBox(height: 4),
              _Indicator(color: ModernTheme.error, text: 'Bloqué', isSquare: true),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: ModernTheme.info,
            value: widget.todo.toDouble(),
            title: '${widget.todo}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: ModernTheme.warning,
            value: widget.inProgress.toDouble(),
            title: '${widget.inProgress}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: ModernTheme.success,
            value: widget.completed.toDouble(),
            title: '${widget.completed}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: ModernTheme.error,
            value: widget.blocked.toDouble(),
            title: '${widget.blocked}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
  });
  final Color color;
  final String text;
  final bool isSquare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(4) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary,
          ),
        )
      ],
    );
  }
}

/// Bar Chart showing Weekly Progress (Mock data for now, can be real later)
class WeeklyProgressBarChart extends StatelessWidget {
  const WeeklyProgressBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
              tooltipHorizontalAlignment: FLHorizontalAlignment.right,
              tooltipMargin: -10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String weekDay;
                switch (group.x) {
                  case 0: weekDay = 'Lun'; break;
                  case 1: weekDay = 'Mar'; break;
                  case 2: weekDay = 'Mer'; break;
                  case 3: weekDay = 'Jeu'; break;
                  case 4: weekDay = 'Ven'; break;
                  case 5: weekDay = 'Sam'; break;
                  case 6: weekDay = 'Dim'; break;
                  default: throw Error();
                }
                return BarTooltipItem(
                  '$weekDay\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY - 1).toString(),
                      style: const TextStyle(
                        color: Colors.white, //widget.touchedBarColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
                reservedSize: 38,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            switch (i) {
              case 0: return makeGroupData(context, 0, 5);
              case 1: return makeGroupData(context, 1, 6.5);
              case 2: return makeGroupData(context, 2, 5);
              case 3: return makeGroupData(context, 3, 7.5);
              case 4: return makeGroupData(context, 4, 9);
              case 5: return makeGroupData(context, 5, 11.5);
              case 6: return makeGroupData(context, 6, 6.5);
              default: return throw Error();
            }
          }),
          gridData: const FlGridData(show: false),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }

  BarChartGroupData makeGroupData(BuildContext context, int x, double y) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [ModernTheme.primaryBlue, ModernTheme.secondaryBlue],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderSide: const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: isDark ? ModernTheme.darkSurfaceVariant : ModernTheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    // This needs context to work with Theme, but getTitles is a callback.
    // We can rely on a Builder or just standard styles if we want, 
    // but the issue is acquiring context inside this callback cleanly without wrapping.
    // However, since it is a widget, we can use a statless widget with context builder inside.
    
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final style = TextStyle(
          color: isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        );
        Widget text;
        switch (value.toInt()) {
          case 0: text = Text('L', style: style); break;
          case 1: text = Text('M', style: style); break;
          case 2: text = Text('M', style: style); break;
          case 3: text = Text('J', style: style); break;
          case 4: text = Text('V', style: style); break;
          case 5: text = Text('S', style: style); break;
          case 6: text = Text('D', style: style); break;
          default: text = Text('', style: style); break;
        }
        return SideTitleWidget(
          axisSide: meta.axisSide,
          space: 16,
          child: text,
        );
      }
    );
  }
}
