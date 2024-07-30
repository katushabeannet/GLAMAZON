import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailsPage extends StatelessWidget {
  final String title;
  final String message;
  final DateTime dateTime;
  final String userName;
  final String salonName;
  final String service;
  final Map<String, dynamic> time;

  const NotificationDetailsPage({
    super.key,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.userName,
    required this.salonName,
    required this.service,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: hexStringToColor("#C0724A"), // Matching color
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'You have a new appointment for $service from $userName at $salonName on ${DateFormat('yyyy-MM-dd').format(dateTime)} at ${TimeOfDay(hour: time['hour'], minute: time['minute']).format(context)}.',
              style: const TextStyle(
                fontSize: 18.0,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
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
