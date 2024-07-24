import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';


class NotificationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Appointment',
      'message': 'You have a new appointment scheduled for July 23, 2024.',
      'dateTime': DateTime.now(),
    },
    {
      'title': 'Payment Received',
      'message': 'You have received a payment of \$50.00 from Jane Doe.',
      'dateTime': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'title': 'Review Received',
      'message': 'You have received a new review from John Smith.',
      'dateTime': DateTime.now().subtract(Duration(days: 2)),
    },
    // Add more notifications as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                style: TextStyle(
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
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}
