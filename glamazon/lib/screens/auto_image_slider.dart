import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:glamazon/screens/ownersignup.dart';
import 'package:glamazon/screens/salon_list.dart';
import 'package:glamazon/screens/signup.dart';
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
    'assets/images/spa1.jpg',
    'assets/images/images (2).jpeg',
    'assets/images/haircut.jpeg',
    'assets/images/peircing1.webp',
    'assets/images/tattoo 1.jpg',
    'assets/images/images (3).jpeg',
    'assets/images/image03.jpg',
    'assets/images/spa.jpeg',
    'assets/images/images (12).jpeg',
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
                // color: Color.fromARGB(255, 215, 162, 1),
                fontFamily: 'Oswald',
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'as a customer') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const signUp()),
                  );
                } else if (result == 'add business') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalonOwnerSignUp()),
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
              // color: const Color.fromARGB(255, 161, 115, 77), // Background color of the drop-down menu
              child: const Text('Join us'),
            ),
          ],
        ),
        elevation: 3,
        // backgroundColor: const Color.fromARGB(255, 161, 115, 77),
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
                  Column(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xFF882D17), size: 30),
                      Text(
                        'Appointments',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Color(0xFF882D17), // Light shade of sienna
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
                  // color: Color(0xFF882D17), // Light shade of sienna
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/images (12).jpeg', 'Hair styling and Cuts'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/images (2).jpeg', 'Nails'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/spa.jpg', 'Spa'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/tatto.jpeg', 'Tattoos'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      _buildServiceItem(context, 'assets/images/makeup1.jpeg', 'Makeup and Facial'),
                      const SizedBox(width: 16.0),
                      _buildServiceItem(context, 'assets/images/piercing 2.jpg', 'Piercing'),
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
                height: 120, // Increased height for larger columns
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
                // color: Color(0xFF882D17), // Light shade of sienna
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

// class AddBusinessScreen extends StatelessWidget {
//   const AddBusinessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Business Screen'),
//       ),
//       body: const Center(
//         child: Text('Add your business details here.'),
//       ),
//     );
//   }
// }
