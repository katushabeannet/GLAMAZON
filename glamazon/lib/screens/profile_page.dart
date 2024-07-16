import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String profileImageUrl;
  final String salonName;
  final String location;
  final String ownerName;
  final String contact;
  final String email;
  final String websiteUrl;
  final String aboutUs;

  const ProfilePage({
    super.key,
    required this.profileImageUrl,
    required this.salonName,
    required this.location,
    required this.ownerName,
    required this.contact,
    required this.email,
    required this.websiteUrl,
    required this.aboutUs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Color.fromARGB(255, 158, 52, 3), // Sienna color
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedData = await Navigator.pushNamed(
                context,
                '/edit-profile',
              );
              if (updatedData != null) {
                // Cast the result to Map<String, dynamic>
                final data = updatedData as Map<String, dynamic>;

                // Update the state with new data
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      profileImageUrl: data['profileImageUrl'],
                      salonName: data['salonName'],
                      location: data['location'],
                      ownerName: data['ownerName'],
                      contact: data['contact'],
                      email: data['email'],
                      websiteUrl: data['websiteUrl'],
                      aboutUs: data['aboutUs'],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(width: 20),
            // Profile Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Name
                  Text(
                    salonName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Sienna color
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Location
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Owner's Name
                  _buildDetailRow('Owner\'s Name', ownerName),
                  const SizedBox(height: 10),
                  // Contact
                  _buildDetailRow('Contact', contact),
                  const SizedBox(height: 10),
                  // Email
                  _buildDetailRow('Email', email),
                  const SizedBox(height: 10),
                  // Website URL
                  _buildDetailRow('Website', websiteUrl),
                  const SizedBox(height: 10),
                  // About Us
                  const Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Sienna color
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    aboutUs,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 238, 134, 86),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Sienna color
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
