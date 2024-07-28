import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/screens/salon_details_page.dart';
import 'package:glamazon/models.dart'; // Correct import

class SalonList extends StatefulWidget {
  const SalonList({super.key});

  @override
  _SalonListState createState() => _SalonListState();
}

class _SalonListState extends State<SalonList> {
  late Future<List<Owner>> ownersFuture;
  List<Owner> allOwners = [];
  List<Owner> filteredOwners = [];
  String selectedService = '';

  @override
  void initState() {
    super.initState();
    ownersFuture = _fetchOwners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Salons'),
        backgroundColor: const Color.fromARGB(179, 181, 81, 31), // Dark Sienna as base color
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Adjust height as needed
          child: _buildServiceButtons(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Owner>>(
              future: ownersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No salons available'));
                }

                if (allOwners.isEmpty) {
                  allOwners = snapshot.data!;
                  filteredOwners = allOwners;
                }

                return ListView.builder(
                  itemCount: filteredOwners.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0), // Increased space
                      child: _buildSalonCard(filteredOwners[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Owner>> _fetchOwners() async {
    var ownerSnapshot = await FirebaseFirestore.instance.collection('owners').get();

    List<Owner> owners = ownerSnapshot.docs.map((doc) {
      return Owner.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
    }).toList();

    return owners;
  }

  Widget _buildServiceButtons() {
    List<Map<String, dynamic>> services = [
      {'name': 'Facial and Makeup', 'enabled': false},
      {'name': 'Hair styling and Cuts', 'enabled': true},
      {'name': 'Nails', 'enabled': true},
      {'name': 'Piercing', 'enabled': false},
      {'name': 'Spa or Massage', 'enabled': true},
      {'name': 'Tattoo', 'enabled': true},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: services.map((service) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: service['enabled'] ? () => _filterSalons(service['name']) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedService == service['name']
                    ? Colors.orange
                    : Color.fromARGB(179, 181, 81, 31),
              ),
              child: Text(service['name']),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _filterSalons(String service) {
    setState(() {
      if (selectedService == service) {
        // Clear filter if the same button is pressed again
        selectedService = '';
        filteredOwners = allOwners;
      } else {
        selectedService = service;
        filteredOwners = allOwners.where((owner) {
          return owner.servicesOffered[service] == true;
        }).toList();
        // Append the rest of the owners that don't have the service at the bottom
        filteredOwners.addAll(allOwners.where((owner) {
          return owner.servicesOffered[service] != true;
        }).toList());
      }
    });
  }

  Widget _buildSalonCard(Owner owner) {
    // Extract services as a comma-separated string
    String services = owner.servicesOffered.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: owner.profileImageUrl.isNotEmpty
                ? Image.network(
                    owner.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/default-salon.jpeg',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/default-salon.jpeg',
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.salonName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 158, 52, 3), // Sienna color
                  ),
                ),
                Text(
                  'Owner: ${owner.ownerName}',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  'Services: $services',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SalonDetailPage(salon: owner),
                        ),
                      );
                    },
                    child: Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
