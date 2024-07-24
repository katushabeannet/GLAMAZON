import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const SettingsPage({required this.onThemeChanged, super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isVibrate = false;
  String _notificationTone = 'Default Tone';
  String _fontSize = 'Medium';
  String _selectedLanguage = 'English';
  String _selectedRegion = 'US';
  String _wallpaperPath = ''; // Provide a default value

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _regions = ['US', 'UK', 'CA', 'AU'];
  final List<String> _popupChoices = ['Choice 1', 'Choice 2', 'Choice 3'];
  final Map<String, bool> _choicesStatus = {
    'Choice 1': false,
    'Choice 2': false,
    'Choice 3': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDarkMode = Theme.of(context).brightness == Brightness.dark;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationsSection(),
          _buildChatsSection(),
          _buildLanguageSection(),
          _buildShareSection(),
          _buildRateUsSection(),
          _buildCustomerSupportSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleMedium, // Updated text style
        ),
        SwitchListTile(
          title: const Text('Vibrate'),
          value: _isVibrate,
          onChanged: (value) {
            setState(() {
              _isVibrate = value;
            });
          },
        ),
        ListTile(
          title: const Text('Notification Tone'),
          subtitle: Text(_notificationTone),
          onTap: _selectNotificationTone,
        ),
        ListTile(
          title: const Text('Popup Choices'),
          onTap: _showPopupChoices,
        ),
        ListTile(
          title: const Text('Ringtone Setting'),
          onTap: _selectRingtone,
        ),
      ],
    );
  }

  Widget _buildChatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chats',
          style: Theme.of(context).textTheme.titleMedium, // Updated text style
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
              widget.onThemeChanged(
                  _isDarkMode); // Notify parent widget of theme change
            });
          },
        ),
        ListTile(
          title: const Text('Wallpaper'),
          subtitle: Text(_wallpaperPath.isEmpty ? 'Default' : _wallpaperPath),
          onTap: _selectWallpaper,
        ),
        ListTile(
          title: const Text('Font Size'),
          subtitle: Text(_fontSize),
          onTap: _selectFontSize,
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.titleMedium, // Updated text style
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_selectedLanguage),
          onTap: _selectLanguage,
        ),
        ListTile(
          title: const Text('Region'),
          subtitle: Text(_selectedRegion),
          onTap: _selectRegion,
        ),
      ],
    );
  }

  Widget _buildShareSection() {
    return ListTile(
      title: const Text('Share Our App'),
      onTap: _shareApp,
    );
  }

  Widget _buildRateUsSection() {
    return ListTile(
      title: const Text('Rate Us'),
      onTap: _rateUs,
    );
  }

  Widget _buildCustomerSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Support',
          style: Theme.of(context).textTheme.titleMedium, // Updated text style
        ),
        ListTile(
          title: const Text('Contact Us'),
          onTap: _contactSupport,
        ),
        ListTile(
          title: const Text('App Info'),
          onTap: _showAppInfo,
        ),
      ],
    );
  }

  void _selectNotificationTone() {
    Fluttertoast.showToast(msg: 'Select Notification Tone');
  }

  void _showPopupChoices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Choices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _popupChoices.map((choice) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(choice),
                Switch(
                  value: _choicesStatus[choice] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _choicesStatus[choice] = value;
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectRingtone() {
    Fluttertoast.showToast(msg: 'Select Ringtone');
  }

  Future<void> _selectWallpaper() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _wallpaperPath = pickedFile.path;
      });
    } else {
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  void _selectFontSize() {
    Fluttertoast.showToast(msg: 'Select Font Size');
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return ListTile(
              title: Text(language),
              onTap: () {
                setState(() {
                  _selectedLanguage = language;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectRegion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _regions.map((region) {
            return ListTile(
              title: Text(region),
              onTap: () {
                setState(() {
                  _selectedRegion = region;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share('Check out this amazing app! [App Link]');
  }

  void _rateUs() {
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.example.my_app');
    _launchURL(url);
  }

  void _contactSupport() {
    final Uri url =
        Uri.parse('mailto:support@example.com?subject=Support Request');
    _launchURL(url);
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Info'),
        content: const Text('Version 1.0.0\nBuild 100'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: 'Could not launch $url');
    }
  }
}
