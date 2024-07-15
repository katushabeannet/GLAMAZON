import 'package:flutter/material.dart';
import 'package:glamazon/screens/salon_details_page.dart';

// Salon Model
class Salon {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> services;

  Salon({required this.id, required this.name, required this.imageUrl, required this.services});

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      services: List<String>.from(json['services']),
    );
  }
}

// Dummy Data
List<Salon> dummySalons = [
  Salon(
    id: '1',
    name: 'Elegant Hair Salon',
    imageUrl: 'assets/images/image10.jpeg',
    services: ['Haircut', 'Coloring', 'Styling'],
  ),
  Salon(
    id: '2',
    name: 'Glamour Nails',
    imageUrl: 'assets/images/image8.jpeg',
    services: ['Manicure', 'Pedicure'],
  ),
  Salon(
    id: '3',
    name: 'Luxury Spa',
    imageUrl: 'assets/images/image3.jpeg',
    services: ['Massage', 'Facial', 'Tattoo'],
  ),
  Salon(
    id: '4',
    name: 'Alberto Unisex',
    imageUrl: 'assets/images/image4.jpeg',
    services: ['Massage', 'Facial', 'Tattoo', 'Haircut'],
  ),
  Salon(
    id: '5',
    name: 'Mama Kaviri',
    imageUrl: 'assets/images/image1.jpeg',
    services: ['Hairplaiting', 'Haircut'],
  ),
  Salon(
    id: '6',
    name: 'Hot looks',
    imageUrl: 'assets/images/image5.jpeg',
    services: ['Makeup', 'Tattoo', 'Manicure'],
  ),
  Salon(
    id: '7',
    name: 'Lady Bird',
    imageUrl: 'assets/images/image2.jpeg',
    services: ['Massage', 'Facial', 'Tattoo'],
  ),
];

// Salon List Screen
class SalonList extends StatefulWidget {
  const SalonList({super.key});

  @override
  _SalonListState createState() => _SalonListState();
}

class _SalonListState extends State<SalonList> {
  late Future<List<Salon>> futureSalons;
  String selectedService = '';

  @override
  void initState() {
    super.initState();
    // Using the dummy data instead of fetching from an API
    futureSalons = Future.value(dummySalons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salons'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildServiceButton('Haircut'),
                _buildServiceButton('Manicure'),
                _buildServiceButton('Massage'),
                _buildServiceButton('Tattoo'),
                _buildServiceButton('Hairplaiting'),
                _buildServiceButton('Makeup'),
                // Add more buttons as needed
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Salon>>(
        future: futureSalons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No salons available'));
          }

          List<Salon> salons = snapshot.data!;
          if (selectedService.isNotEmpty) {
            salons.sort((a, b) {
              bool aHasService = a.services.contains(selectedService);
              bool bHasService = b.services.contains(selectedService);
              return aHasService == bHasService ? 0 : (aHasService ? -1 : 1);
            });
          }

          return ListView.builder(
            itemCount: salons.length,
            itemBuilder: (context, index) {
              return _buildSalonCard(salons[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceButton(String service) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedService = service;
          });
        },
        child: Text(service),
      ),
    );
  }

  Widget _buildSalonCard(Salon salon) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                salon.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      salon.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SalonDetailPage(salon: salon)),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




