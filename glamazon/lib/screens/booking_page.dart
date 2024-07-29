import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  BookingPage({required this.salonId, required this.salonName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<String> services = [];
  String? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      var ownerSnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .doc(widget.salonId)
          .get();

      if (ownerSnapshot.exists) {
        var ownerData = ownerSnapshot.data()!;
        var servicesOffered = Map<String, bool>.from(ownerData['servicesOffered'] ?? {});

        setState(() {
          services = servicesOffered.keys.where((key) => servicesOffered[key]!).toList();
          if (services.isNotEmpty) {
            selectedService = services[0];
          }
        });
      }
    } catch (e) {
      print('Error fetching salon services: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Book at ${widget.salonName}', style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(179, 181, 81, 31),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedService,
              decoration: InputDecoration(
                labelText: 'Select Service',
                border: OutlineInputBorder(),
              ),
              items: services.map((service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedService = newValue;
                });
              },
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text("Time: ${selectedTime.format(context)}"),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Handle booking submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 164, 100, 68),
              ),
              child: Text('Submit Booking', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
