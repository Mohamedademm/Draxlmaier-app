import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(localizations.translate('profile')),
            subtitle: Text(authProvider.currentUser?.email ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(localizations.translate('notifications')),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue / Language'),
            subtitle: Text(localeProvider.locale.languageCode == 'fr' 
                ? 'Français' 
                : 'English'),
            trailing: PopupMenuButton<String>(
              onSelected: (String languageCode) {
                localeProvider.setLocale(Locale(languageCode));
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'fr',
                  child: Row(
                    children: [
                      Text('🇫🇷 '),
                      SizedBox(width: 8),
                      Text('Français'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Text('🇬🇧 '),
                      SizedBox(width: 8),
                      Text('English'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.arrow_drop_down),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Mode sombre / Dark Mode'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos / About'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialité / Privacy Policy'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              localizations.translate('logout'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              authProvider.logout();
            },
          ),
        ],
      ),
    );
  }
}
