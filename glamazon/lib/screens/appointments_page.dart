import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _fetchAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No appointments found.'));
            }

            final appointments = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final requestedTime = appointment['time'];
                DateTime appointmentDateTime = appointment['date'] != null 
                    ? (appointment['date'] as Timestamp).toDate() 
                    : DateTime.now(); // Default to now if the date is null

                return FutureBuilder<DocumentSnapshot>(
                  future: _fetchUserDetails(appointment['userId']),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (userSnapshot.hasError) {
                      return Center(child: Text('Error: ${userSnapshot.error}'));
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Center(child: Text('User details not found.'));
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final userName = userData['username'] ?? 'Unknown User';
                    final contactNumber = userData['phone'] ?? 'N/A';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 4.0,
                        color: hexStringToColor("#E0A680"), // Lighter sienna color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Contact: $contactNumber',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Service: ${appointment['service'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(appointmentDateTime)} (${DateFormat('EEEE').format(appointmentDateTime)})',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Time: ${TimeOfDay(hour: requestedTime['hour'], minute: requestedTime['minute']).format(context)}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchAppointments() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('salonId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<DocumentSnapshot> _fetchUserDetails(String userId) async {
    try {
      return await FirebaseFirestore.instance.collection('users').doc(userId).get();
    } catch (e) {
      print("Error fetching user details: $e");
      rethrow;
    }
  }
}

// Utility function to convert hex string to color
Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}
