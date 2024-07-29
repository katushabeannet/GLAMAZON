import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';
// import '../utils/colors.dart';

class SettingsOwner extends StatefulWidget {
  const SettingsOwner({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsOwner> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Account'),
            leading: Icon(Icons.person, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to account settings
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Notifications'),
            leading:
                Icon(Icons.notifications, color: hexStringToColor("#C0724A")),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Dark Mode'),
            leading:
                Icon(Icons.brightness_6, color: hexStringToColor("#C0724A")),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            leading: Icon(Icons.language, color: hexStringToColor("#C0724A")),
            trailing: DropdownButton<String>(
              value: _language,
              onChanged: (String? newValue) {
                setState(() {
                  _language = newValue!;
                });
              },
              items: <String>['English', 'Spanish', 'French', 'German']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy'),
            leading: Icon(Icons.lock, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            leading: Icon(Icons.info, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to about page
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: Icon(Icons.logout, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
