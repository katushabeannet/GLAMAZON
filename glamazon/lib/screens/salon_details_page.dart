import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/models.dart';
import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/rating_page.dart';
// import 'package:glamazon/models.dart'; // Correct import

class SalonDetailPage extends StatefulWidget {
  final Owner salon;

  SalonDetailPage({required this.salon});

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
  }

  Future<void> _fetchGallery() async {
    var gallerySnapshot = await FirebaseFirestore.instance
        .collection('owners_gallery')
        .doc(widget.salon.id) // assuming salonId is the document ID in owners_gallery
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('${widget.salon.salonName} Details', style: TextStyle(color: Colors.black)),
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
                    backgroundImage: widget.salon.profileImageUrl.isNotEmpty
                        ? NetworkImage(widget.salon.profileImageUrl)
                        : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  SizedBox(width: 20),
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
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingPage(salonId: '', salonName: '')),
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
                                          salonId: widget.salon.salonName,
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
              const SizedBox(height: 20),
              Text(
                'Location: ${widget.salon.location}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Contact: ${widget.salon.contact}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Working Days: ${widget.salon.workingDays}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Working Hours: ${widget.salon.workingHours}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Services Offered:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildServices(widget.salon.servicesOffered),
              SizedBox(height: 20),
              Text(
                'Gallery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildGallery(galleryItems),
              SizedBox(height: 20),
              Text(
                'Ratings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildRatingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGallery(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Text('No gallery items available.');
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Container(
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Time taken: ${item['timeTaken']} hours',
                  style: TextStyle(color: Colors.black54),
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
      return Text('No services available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: servicesOffered.entries
          .where((entry) => entry.value)
          .map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0), // Reduced vertical padding
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
