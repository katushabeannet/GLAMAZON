import 'package:flutter/material.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
import 'package:glamazon/screens/settings_owner.dart';
import 'appointments_page.dart';
import 'chat-page.dart';
import 'notifications.dart';

class SalonOwnerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salon Owner Home'),
        backgroundColor:
            hexStringToColor("#C0724A"), // Matching the gradient colors
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/eagle.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salon Name',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: hexStringToColor("#C0724A"), // Matching color
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: <Widget>[
                  _buildGridButton(
                    context,
                    Icons.person,
                    'My Profile',
                    () {
                      // Navigate to My Profile page
                    },
                  ),
                  _buildGridButton(
                    context,
                    Icons.notifications,
                    'Notifications',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                    },
                  ),
                  // _buildGridButton(
                  //   context,
                  //   Icons.assignment,
                  //   'Applications',
                  //   () {
                  //     // Navigate to Applications page
                  //   },
                  // ),
                  _buildGridButton(
                    context,
                    Icons.chat,
                    'Chat Room',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    Icons.calendar_today,
                    'Appointments',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppointmentsPage()),
                      );
                    },
                  ),
                  _buildGridButton(context, Icons.settings, 'Settings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsOwner()),
                    );
                  }),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyImageSlider()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hexStringToColor("#C0724A"), // Matching color
                  foregroundColor: Colors.white,
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (event) => _onHover(context, true),
      onExit: (event) => _onHover(context, false),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40.0,
                color: hexStringToColor("#089be3"), // Matching color
              ),
              SizedBox(height: 10.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: hexStringToColor("#C0724A"), // Matching color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onHover(BuildContext context, bool isHovering) {
    // Handle hover effect if needed
  }
}
