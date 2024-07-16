import 'package:flutter/material.dart';
import 'package:glamazon/screens/splash.dart';
import 'package:glamazon/screens/profile_page.dart'; // Import ProfilePage
import 'package:glamazon/screens/edit_profile_page.dart'; // Import EditProfilePage

void main() {
  runApp(const MyApplication());
}

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Splash(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/profile': (context) => const ProfilePage(
              profileImageUrl: 'https://example.com/profile.jpg',
              salonName: 'Glamazon Salon',
              location: '123 Beauty Street, Glamour City',
              ownerName: 'Alinda Tracy',
              contact: '123-456-7890',
              email: 'alinda.tracy@example.com',
              websiteUrl: 'https://example.com',
              aboutUs:
                  'Welcome to Glamazon Salon, where beauty meets excellence!',
            ),
        '/edit-profile': (context) => const EditProfilePage(),
      },
    );
  }
}
