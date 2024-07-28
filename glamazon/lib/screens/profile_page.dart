import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glamazon/screens/salonownerhome%20copy.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageUrl;
  String salonName = '';
  String location = '';
  String ownerName = '';
  String contact = '';
  String email = '';
  String workingDays = '';
  String workingHours = '';
  Map<String, bool> servicesOffered = {
    'Hair styling and Cuts': false,
    'Nails': false,
    'Spa or Massage': false,
    'Tattoo': false,
    'Facial and Makeup': false,
    'Piercing': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    final profileDoc = await FirebaseFirestore.instance.collection('owners').doc(user.uid).get();
    final data = profileDoc.data();
    if (data != null) {
      setState(() {
        profileImageUrl = data['profileImageUrl'];
        salonName = data['salonName'];
        location = data['location'];
        ownerName = data['ownerName'];
        contact = data['contact'];
        email = data['email'];
        workingDays = data['workingDays'] ?? 'Monday to Saturday';
        workingHours = data['workingHours'] ?? '';
        if (data['servicesOffered'] != null) {
          servicesOffered = Map<String, bool>.from(data['servicesOffered']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Color.fromARGB(255, 158, 52, 3), // Sienna color
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedData = await Navigator.pushNamed(context, '/edit-profile');
              if (updatedData != null) {
                _fetchProfileData();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/images/default.png') as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  // Salon Name and Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 158, 52, 3), // Sienna color
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile Details
              _buildDetailRow('Owner\'s Name', ownerName),
              const SizedBox(height: 10),
              _buildDetailRow('Contact', contact),
              const SizedBox(height: 10),
              _buildDetailRow('Email', email),
              const SizedBox(height: 10),
              _buildDetailRow('Working Days', workingDays),
              const SizedBox(height: 10),
              _buildDetailRow('Working Hours', workingHours),
              const SizedBox(height: 10),
              const Text(
                'Services Offered',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 158, 52, 3), // Sienna color
                ),
              ),
              const SizedBox(height: 5),
              ...servicesOffered.entries
                  .where((entry) => entry.value) // Only display services that are offered (true)
                  .map((entry) {
                    int index = servicesOffered.keys.toList().indexOf(entry.key) + 1;
                    return Text(
                      '$index. ${entry.key}',
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 158, 52, 3)), // Sienna color
                    );
                  })
                  .toList(),
              const SizedBox(height: 20),
              // Redirect Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SalonOwnerHome()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 158, 52, 3), // Sienna color
                  ),
                  child: Text('Go to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 158, 52, 3), // Sienna color
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
