import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatelessWidget {
  final List<Map<String, dynamic>> appointments = [
    {
      'userName': 'John Doe',
      'contactNumber': '123-456-7890',
      'serviceName': 'Haircut',
      'requestedTime': DateTime(2024, 7, 23, 14, 0),
    },
    {
      'userName': 'Jane Smith',
      'contactNumber': '987-654-3210',
      'serviceName': 'Manicure',
      'requestedTime': DateTime(2024, 7, 23, 16, 0),
    },
    // Add more appointments here...
  ];

 AppointmentsPage({super.key});

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
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
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
                        appointment['userName'],
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Contact: ${appointment['contactNumber']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Service: ${appointment['serviceName']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(appointment['requestedTime'])} (${DateFormat('EEEE').format(appointment['requestedTime'])})',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Time: ${DateFormat('hh:mm a').format(appointment['requestedTime'])}',
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
