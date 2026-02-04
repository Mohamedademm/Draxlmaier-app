import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

class ModernMainLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavigationChanged;
  final List<NavigationItem> items;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const ModernMainLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.items,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                _ModernSidebar(
                  currentIndex: currentIndex,
                  onTap: onNavigationChanged,
                  items: items,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(ModernTheme.radiusL),
                      bottomLeft: Radius.circular(ModernTheme.radiusL),
                    ),
                    child: Container(
                      color: isDark ? ModernTheme.darkBackground : ModernTheme.background,
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
        
        return Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar: _ModernBottomNavBar(
            currentIndex: currentIndex,
            onTap: onNavigationChanged,
            items: items,
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int? badgeCount;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}

class _ModernSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const _ModernSidebar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 250,
      color: isDark ? ModernTheme.darkSurface : ModernTheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Draxlmaier',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : ModernTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentIndex == index;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? ModernTheme.primaryBlue.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected 
                                ? ModernTheme.primaryBlue 
                                : (isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected 
                                  ? ModernTheme.primaryBlue 
                                  : (isDark ? ModernTheme.darkTextSecondary : ModernTheme.textSecondary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ModernTheme.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const _ModernBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.darkSurface : ModernTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;
              
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? ModernTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected 
                                ? ModernTheme.primaryBlue 
                                : (isDark ? ModernTheme.darkTextTertiary : ModernTheme.textTertiary),
                            size: 22,
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: ModernTheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: isDark ? ModernTheme.darkSurface : ModernTheme.surface,
                                      width: 1.5
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected 
                              ? ModernTheme.primaryBlue 
                              : (isDark ? ModernTheme.darkTextTertiary : ModernTheme.textTertiary),
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
