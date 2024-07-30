import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/models.dart';
import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/chat-page.dart';
import 'package:glamazon/screens/customer-home.dart';
import 'package:glamazon/screens/rating_page.dart';
 // Add this import

class SalonDetailPage extends StatefulWidget {
  final Owner salon;

  const SalonDetailPage({super.key, required this.salon});

  @override
  _SalonDetailPageState createState() => _SalonDetailPageState();
}

class _SalonDetailPageState extends State<SalonDetailPage> {
  List<Map<String, dynamic>> ratings = [];
  List<Map<String, dynamic>> galleryItems = [];

  @override
  void initState() {
    super.initState();
    _fetchGallery();
    _fetchRatings();
  }

  Future<void> _fetchGallery() async {
    var gallerySnapshot = await FirebaseFirestore.instance
        .collection('owners_gallery')
        .doc(widget.salon.id)
        .collection('gallery')
        .get();

    setState(() {
      galleryItems = gallerySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'timeTaken': doc['timeTaken'],
          'url': doc['url'],
        };
      }).toList();
    });
  }

  Future<void> _fetchRatings() async {
    var ratingsSnapshot = await FirebaseFirestore.instance
        .collection('salons')
        .doc(widget.salon.id)
        .collection('ratings')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      ratings = ratingsSnapshot.docs.map((doc) {
        return {
          'rating': doc['rating'],
          'comment': doc['comment'],
        };
      }).toList();
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImageSlider()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('${widget.salon.salonName} Details', style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(179, 181, 81, 31),
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
                    backgroundImage: widget.salon.profileImageUrl.isNotEmpty
                        ? NetworkImage(widget.salon.profileImageUrl)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.salon.salonName,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    salonId: widget.salon.id,
                                    salonName: widget.salon.salonName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 164, 100, 68),
                            ),
                            child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                          ),

                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RatingsPage(
                                          salonId: widget.salon.id,
                                        )),
                              );
                              if (result != null) {
                                setState(() {
                                  ratings.add(result);
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 164, 100, 68),
                            ),
                            child: const Text('Rate Us', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Location: ${widget.salon.location}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Contact: ${widget.salon.contact}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Working Days: ${widget.salon.workingDays}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Working Hours: ${widget.salon.workingHours}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Services Offered:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildServices(widget.salon.servicesOffered),
              const SizedBox(height: 20),
              const Text(
                'Gallery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildGallery(galleryItems),
              const SizedBox(height: 20),
              const Text(
                'Ratings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildRatingsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatroom',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildGallery(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Text('No gallery items available.');
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    item['url']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Time taken: ${item['timeTaken']} hours',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildServices(Map<String, bool> servicesOffered) {
    if (servicesOffered.isEmpty) {
      return const Text('No services available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: servicesOffered.entries
          .where((entry) => entry.value)
          .map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(entry.key),
                ],
              ),
            );
          })
          .toList(),
    );
  }

  Widget buildRatingsSection() {
    if (ratings.isEmpty) {
      return const Text('No ratings yet.');
    }
    return Column(
      children: ratings.map((rating) {
        return ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: Text('Rating: ${rating['rating']}'),
          subtitle: Text(rating['comment'] ?? 'No comment provided'),
        );
      }).toList(),
    );
  }
}
