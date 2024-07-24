import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';
// import '../utils/colors.dart';

class SettingsOwner extends StatefulWidget {
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
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Account'),
            leading: Icon(Icons.person, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to account settings
            },
          ),
          Divider(),
          ListTile(
            title: Text('Notifications'),
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
          Divider(),
          ListTile(
            title: Text('Dark Mode'),
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
          Divider(),
          ListTile(
            title: Text('Language'),
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
          Divider(),
          ListTile(
            title: Text('Privacy'),
            leading: Icon(Icons.lock, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          Divider(),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info, color: hexStringToColor("#C0724A")),
            onTap: () {
              // Navigate to about page
            },
          ),
          Divider(),
          ListTile(
            title: Text('Logout'),
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
