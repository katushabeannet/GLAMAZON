import 'package:flutter/material.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/chat-page.dart';
import 'package:glamazon/screens/profile_page.dart';
import 'package:glamazon/screens/rating_page.dart';
// Ensure proper import

import 'salon_list.dart';

class SalonDetailPage extends StatefulWidget {
  final Salon salon;

  SalonDetailPage({required this.salon});

  @override
  _SalonDetailPageState createState() => _SalonDetailPageState();
}

class _SalonDetailPageState extends State<SalonDetailPage> {
  List<Map<String, dynamic>> ratings = [];

  final List<Map<String, String>> galleryItems = [
    {'imagePath': 'assets/images/haircut.jpeg', 'name': 'Glamorous Updo'},
    {'imagePath': 'assets/images/makeup1.jpeg', 'name': 'Elegant Braids'},
    {'imagePath': 'assets/images/images (1).jpeg', 'name': 'Classic Curls'},
    {'imagePath': 'assets/images/images (2).jpeg', 'name': 'Sleek Bob'},
    {'imagePath': 'assets/images/images (3).jpeg', 'name': 'Sleek Bob'},
    {'imagePath': 'assets/images/images (8).jpeg', 'name': 'Sleek Bob'},
    {'imagePath': 'assets/images/image03.jpg', 'name': 'Sleek Bob'},
    // Add more images and names as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Glamazon', style: TextStyle(color: Colors.black)),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () {
                // Navigate to the ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      // profileImageUrl: '',
                      // salonName: '',
                      // location: '',
                      // ownerName: '',
                      // contact: '',
                      // email: '',
                      // websiteUrl: '',
                      // aboutUs: '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(179, 181, 81, 31), // Dark Sienna as base color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(widget.salon.imageUrl),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.salon.name,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingPage(
                                          salonId: widget.salon.id,
                                          salonName: widget.salon.name,
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 164, 100, 68), // Sienna color
                            ),
                            child: Text('Book Now',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RatingsPage(
                                          salonId: '',
                                        )),
                              );
                              if (result != null) {
                                setState(() {
                                  ratings.add(result);
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 164, 100, 68), // Sienna color
                            ),
                            child: Text('Rate Us',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Services: ${widget.salon.services.join(', ')}'),
              SizedBox(height: 20),
              Text(
                'Gallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildGallery(galleryItems),
              SizedBox(height: 20),
              Text(
                'Ratings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              buildRatingsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(179, 181, 81, 31),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black, // Darker Sienna shade
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.black, // Darker Sienna shade
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyImageSlider()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          }
        },
      ),
    );
  }

  Widget buildGallery(List<Map<String, String>> galleryItems) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      children: galleryItems.map((item) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.asset(
                    item['imagePath']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item['name']!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildRatingsSection() {
    if (ratings.isEmpty) {
      return Text('No ratings yet.');
    }
    return Column(
      children: ratings.map((rating) {
        return ListTile(
          leading: Icon(Icons.star, color: Colors.amber),
          title: Text('Rating: ${rating['rating']}'),
          subtitle: Text(rating['comment'] ?? 'No comment provided'),
        );
      }).toList(),
    );
  }
}
