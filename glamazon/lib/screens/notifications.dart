import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glamazon/screens/notification-deatails.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _listenForAppointments();
  }

  void _listenForAppointments() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      print('No user is logged in');
      return;
    }

    FirebaseFirestore.instance
        .collection('appointments')
        .where('salonId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> tempNotifications = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        var userId = data['userId'];

        // Fetch user details
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        var userName = (userDoc.exists && userDoc.data() != null) ? userDoc.data()!['username'] ?? 'Unknown User' : 'Unknown User';
        var phoneNumber = (userDoc.exists && userDoc.data() != null) ? userDoc.data()!['phone'] ?? 'N/A' : 'N/A';

        tempNotifications.add({
          'title': 'New Appointment',
          'message': 'You have a new appointment for ${data['service']} from $userName at ${data['salonName']} on ${DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate())} at ${TimeOfDay(hour: data['time']['hour'], minute: data['time']['minute']).format(context)}.',
          'dateTime': (data['date'] as Timestamp).toDate(),
          'userName': userName,
          'salonName': data['salonName'],
          'service': data['service'],
          'time': data['time'],
          'phoneNumber': phoneNumber
        });
      }

      setState(() {
        notifications = tempNotifications;
        notifications.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Icon(Icons.notifications,
                  color: hexStringToColor("#089be3")), // Matching color
              title: Text(
                notifications[index]['title']!,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: hexStringToColor("#C0724A"), // Matching color
                ),
              ),
              subtitle: Text(
                notifications[index]['message']!,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailsPage(
                      title: notifications[index]['title']!,
                      message: notifications[index]['message']!,
                      dateTime: notifications[index]['dateTime']!,
                      userName: notifications[index]['userName']!,
                      salonName: notifications[index]['salonName']!,
                      service: notifications[index]['service']!,
                      time: notifications[index]['time']!,
                      phoneNumber: notifications[index]['phoneNumber']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
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
