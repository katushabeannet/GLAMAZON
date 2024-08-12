import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/screens/customer_chats.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatelessWidget {
  final String appointmentId;
  final String title;
  final String message;
  final DateTime dateTime;
  final String userName;
  final String salonName;
  final String service;
  final String time;
  final String phoneNumber;

  const NotificationDetailPage({
    Key? key,
    required this.appointmentId,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.userName,
    required this.salonName,
    required this.service,
    required this.time,
    required this.phoneNumber,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: hexStringToColor("#C0724A"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchAppointmentDetails(appointmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Appointment details not found.'));
          }

          final appointment = snapshot.data!.data() as Map<String, dynamic>;
          final requestedTime = appointment['time'];
          DateTime appointmentDateTime = appointment['date'] != null
              ? (appointment['date'] as Timestamp).toDate()
              : DateTime.now();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Service: ${appointment['service'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(appointmentDateTime)} (${DateFormat('EEEE').format(appointmentDateTime)})',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Time: ${TimeOfDay(hour: requestedTime['hour'], minute: requestedTime['minute']).format(context)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchAppointmentDetails(String appointmentId) async {
    try {
      return await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).get();
    } catch (e) {
      print("Error fetching appointment details: $e");
      rethrow;
    }
  }
}
