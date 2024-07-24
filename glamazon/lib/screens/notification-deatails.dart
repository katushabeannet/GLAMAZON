import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatefulWidget {
  final String title;
  final String message;
  final DateTime dateTime;

  NotificationDetailsPage({
    required this.title,
    required this.message,
    required this.dateTime,
  });

  @override
  _NotificationDetailsPageState createState() =>
      _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final TextEditingController replyController = TextEditingController();
  List<String> replies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Notification Details'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: hexStringToColor("#C0724A"), // Matching color
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.dateTime.toLocal().toString(),
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 18.0,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Replies:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      replies[index],
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: replyController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Reply',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String reply = replyController.text;
                if (reply.isNotEmpty) {
                  setState(() {
                    replies.add(reply);
                  });
                  replyController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reply sent successfully!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hexStringToColor("#C0724A"), // Matching color
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Text(
                'Send Reply',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
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
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}
