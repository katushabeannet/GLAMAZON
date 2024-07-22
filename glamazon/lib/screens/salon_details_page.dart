import 'package:flutter/material.dart';
import 'package:glamazon/screens/auto_image_slider.dart';
import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/chat_room_page.dart';
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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Glamazon', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // Navigate to the ProfilePage
                Navigator.push(
                   context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      profileImageUrl: '',
                      salonName: '',
                      location: '',
                      ownerName: '',
                      contact: '',
                      email: '',
                      websiteUrl: '',
                      aboutUs: '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF882D17), // Dark Sienna as base color
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
                        style: TextStyle(
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
                                          salonId: '',
                                          salonName: '',
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFAA4A30), // Sienna color
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
                              backgroundColor: Color(0xFFAA4A30), // Sienna color
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
        backgroundColor: Color(0xFFAA4A30),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white, // Darker Sienna shade
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.white, // Darker Sienna shade
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
              MaterialPageRoute(builder: (context) => ChatRoomPage()),
            );
          }
        },
      ),
    );
  }

  Widget buildGallery(List<Map<String, String>> galleryItems) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: galleryItems.map((item) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  item['imagePath']!,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['name']!,
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
