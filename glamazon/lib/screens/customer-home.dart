import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
// import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/profile-details.dart';
import 'package:glamazon/screens/profile-edit.dart';
import 'package:glamazon/screens/salon_list.dart';
import 'package:glamazon/screens/user_appointments.dart';
import 'package:glamazon/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      title: 'Glamazon',
      home: const ImageSlider(),
      routes: {
        '/serviceDetails': (context) => const SalonList(),
        '/home': (context) => const MyImageSlider(),
        '/profile': (context) => const ProfileEditScreen(),
      },
    );
  }
}

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final myItems = [
    'assets/images/spa/spa1.jpg',
    'assets/images/nails/images (2).jpeg',
    'assets/images/hair/haircut.jpeg',
    'assets/images/piercing/peircing1.webp',
    'assets/images/tatoo/tattoo 1.jpg',
    'assets/images/nails/images (3).jpeg',
    'assets/images/makeup/image03.jpg',
    'assets/images/spa/spa.jpeg',
    'assets/images/hair/images (12).jpeg',
  ];

  int myCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Glamazon',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((Value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyImageSlider()),
                  );
                });
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Image(
                    image: AssetImage('assets/images/logo3.png'),
                    height: 90,
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFF882D17), size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserAppointmentsPage()),
                          );
                        },
                      ),
                      const Text(
                        'Appointments',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person, color: Color(0xFF882D17), size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  height: 200,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayInterval: const Duration(seconds: 2),
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      myCurrentIndex = index;
                    });
                  },
                ),
                items: myItems.map((item) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'services available ...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/hair/images (8).jpeg', 'Hair styling and Cuts'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/nails/image02.jpg', 'Nails'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/spa/spa.jpg', 'Spa'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/tatoo/image14.jpeg', 'Tattoos'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/makeup/makeup2.jpeg', 'Makeup and Facial'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/piercing/piercing 2.jpg', 'Piercing'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String imagePath, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalonList()),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
