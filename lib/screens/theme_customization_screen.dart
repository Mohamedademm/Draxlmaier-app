import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_widgets.dart';
import '../providers/theme_provider.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  Color selectedPrimary = ModernTheme.primaryBlue;
  bool isDarkMode = false;

  final List<Color> presetColors = [
    const Color(0xFF003DA5),
    const Color(0xFF1E88E5),
    const Color(0xFF2E7D32),
    const Color(0xFFD32F2F),
    const Color(0xFF7B1FA2),
    const Color(0xFFE65100),
    const Color(0xFF263238),
    const Color(0xFF006064),
  ];

  @override
  void initState() {
    super.initState();
    final themeProvider = context.read<ThemeProvider>();
    selectedPrimary = themeProvider.primaryColor;
    isDarkMode = themeProvider.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(
        title: 'Personnalisation',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 24),
            
            Text(
              'Couleur Principale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildColorGrid(),
            
            const SizedBox(height: 32),
            
            Text(
              'Mode d\'affichage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ModernCard(
              child: SwitchListTile(
                title: const Text('Mode Sombre'),
                subtitle: const Text('Activer l\'interface sombre pour la nuit'),
                value: isDarkMode,
                activeColor: selectedPrimary,
                onChanged: (val) => setState(() => isDarkMode = val),
              ),
            ),
            
            const SizedBox(height: 48),
            
            GradientButton(
              text: 'Enregistrer les modifications',
              onPressed: () async {
                final themeProvider = context.read<ThemeProvider>();
                await themeProvider.updatePrimaryColor(selectedPrimary);
                await themeProvider.toggleThemeMode(isDarkMode);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thème mis à jour avec succès !'),
                      backgroundColor: selectedPrimary,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu',
          style: TextStyle(fontWeight: FontWeight.bold, color: ModernTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: selectedPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: selectedPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Draxlmaier Mobile',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedPrimary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: selectedPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white24 : Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white12 : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Action', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: presetColors.length,
      itemBuilder: (context, index) {
        final color = presetColors[index];
        final isSelected = selectedPrimary == color;
        
        return InkWell(
          onTap: () => setState(() => selectedPrimary = color),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: isSelected ? const Center(child: Icon(Icons.check, color: Colors.white)) : null,
          ),
        );
      },
    );
  }
}
