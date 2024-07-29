import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsPage extends StatefulWidget {
  final String salonId;

  RatingsPage({required this.salonId});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  double _rating = 0.0;
  TextEditingController _commentController = TextEditingController();

  void _saveRating() async {
    try {
      await FirebaseFirestore.instance
          .collection('salons')
          .doc(widget.salonId)
          .collection('ratings')
          .add({
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Rating saved successfully');
    } catch (e) {
      print('Error saving rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Rate Salon'),
        backgroundColor: Color.fromARGB(179, 181, 81, 31),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this Salon:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveRating();
                Navigator.pop(context, {
                  'rating': _rating,
                  'comment': _commentController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAA4A30),
              ),
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
