import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:glamazon/screens/ownersignup.dart';
import 'package:glamazon/screens/salon_list.dart';
import 'package:glamazon/screens/salonownerlogin.dart';
import 'package:glamazon/screens/signin.dart';
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
      home: const MyImageSlider(),
      routes: {
        '/customer': (context) => const CustomerScreen(),
        '/addBusiness': (context) => SalonOwnerSignUp(),
        '/serviceDetails': (context) => const SalonList(),
      },
    );
  }
}

class MyImageSlider extends StatefulWidget {
  const MyImageSlider({super.key});

  @override
  State<MyImageSlider> createState() => _MyImageSliderState();
}

class _MyImageSliderState extends State<MyImageSlider> {
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
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'as a customer') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                  );
                } else if (result == 'add business') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalonOwnerLogin()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'as a customer',
                  child: Text('as a customer'),
                ),
                const PopupMenuItem<String>(
                  value: 'add business',
                  child: Text('add business'),
                ),
              ],
              child: const Text('Join us'),
            ),
          ],
        ),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo3.png'), // Replace with your logo asset path
                    height: 90,
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text.rich(
                  TextSpan(
                    text: 'Select ',
                    style: TextStyle(color: Colors.blue), // Change this color to your desired color
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Join us',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                content: const Text(
                  'Please sign up or log in to access this service.',
                  style: TextStyle(color: Colors.blue), // Same color as the 'Select' word
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
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

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Screen'),
      ),
      body: const Center(
        child: Text('Welcome, Customer!'),
      ),
    );
  }
}
