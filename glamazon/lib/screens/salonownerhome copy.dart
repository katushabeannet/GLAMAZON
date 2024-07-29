import 'package:flutter/material.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
import 'package:glamazon/screens/owner-gallery.dart';
import 'package:glamazon/screens/ownerchat_page.dart';
import 'package:glamazon/screens/profile_page.dart';
import 'package:glamazon/screens/settings_owner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointments_page.dart';
import 'notifications.dart';

class SalonOwnerHome extends StatefulWidget {
  const SalonOwnerHome({super.key});

  @override
  _SalonOwnerHomeState createState() => _SalonOwnerHomeState();
}

class _SalonOwnerHomeState extends State<SalonOwnerHome> {
  String salonName = '';
  String location = '';
  String? profileImageUrl;
  bool _isLoading = true; // Added variable to manage loading state

  @override
  void initState() {
    super.initState();
    _fetchSalonDetails();
  }

  Future<void> _fetchSalonDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profileDoc = await FirebaseFirestore.instance.collection('owners').doc(user.uid).get();
        final data = profileDoc.data();
        if (data != null) {
          setState(() {
            salonName = data['salonName'] ?? 'Salon Name';
            location = data['location'] ?? 'Location';
            profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print('Error fetching salon details: $e');
      // Optionally, you can show an error message to the user
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after fetching data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('My Salon'),
        backgroundColor: const Color.fromARGB(179, 181, 81, 31), // Matching the gradient colors
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ? Image.network(
                                profileImageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salonName,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: hexStringToColor("#C0724A"), // Matching color
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
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
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        _buildGridButton(
                          context,
                          Icons.photo_album_outlined,
                          'Gallery',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SalonDetails(),
                              ),
                            );
                          },
                        ),
                        _buildGridButton(
                          context,
                          Icons.chat,
                          'Chat Room',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OwnerChatPage(),
                              ),
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
                                builder: (context) => AppointmentsPage(),
                              ),
                            );
                          },
                        ),
                        _buildGridButton(
                          context,
                          Icons.settings,
                          'Settings',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsOwner(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((Value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyImageSlider(),
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hexStringToColor("#C0724A"), // Matching color
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGridButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
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
              const SizedBox(height: 10.0),
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

  Color hexStringToColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.black;
  }
}
