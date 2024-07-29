import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glamazon/screens/reschedule_page.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  BookingPage({required this.salonId, required this.salonName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Map<String, Duration> servicesWithDurations = {};
  String? selectedService;
  DateTime? selectedDate;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  bool isSlotAvailable = true;
  bool isAppointmentConfirmed = false;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> salonBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchSalonServices();
    _fetchSalonBookings();
  }

  Future<void> _fetchSalonServices() async {
    try {
      DocumentSnapshot salonSnapshot = await FirebaseFirestore.instance
          .collection('salons')
          .doc(widget.salonId)
          .get();

      if (salonSnapshot.exists) {
        Map<String, dynamic> services = salonSnapshot.get('servicesOffered');
        setState(() {
          servicesWithDurations = services.map((key, value) => MapEntry(key, Duration(minutes: value)));
        });
      } else {
        print("Salon document does not exist.");
      }
    } catch (e) {
      print("Error fetching salon services: $e");
    }
  }

  Future<void> _fetchSalonBookings() async {
    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .get();

      setState(() {
        salonBookings = bookingsSnapshot.docs.map((doc) {
          return {
            'start': doc['start'].toDate(),
            'end': doc['end'].toDate(),
            'service': doc['service'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching salon bookings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book an Appointment at ${widget.salonName}'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedService,
              hint: const Text('Select a Service'),
              items: servicesWithDurations.keys.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedService = newValue;
                  selectedStartTime = null;
                  selectedEndTime = null;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            if (selectedDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Taken Slots:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._getTakenSlots().map((slot) => Text(
                      '${DateFormat('HH:mm').format(slot['start']!)} - ${DateFormat('HH:mm').format(slot['end']!)}')).toList(),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(selectedStartTime == null
                        ? 'Select Start Time'
                        : DateFormat('kk:mm').format(selectedStartTime!)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                  if (selectedStartTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'End Time: ${DateFormat('kk:mm').format(selectedEndTime!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookAppointment,
              child: const Text('Confirm Appointment'),
            ),
            if (!isSlotAvailable)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Selected time slot is already taken. Please choose another time.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ..._buildAppointmentContainers(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        selectedStartTime = null;
        selectedEndTime = null;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && selectedDate != null && selectedService != null) {
      setState(() {
        selectedStartTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        selectedEndTime = selectedStartTime!.add(servicesWithDurations[selectedService]!);
      });
    }
  }

  List<Map<String, dynamic>> _getTakenSlots() {
    return salonBookings
        .where((slot) =>
            slot['start']!.year == selectedDate?.year &&
            slot['start']!.month == selectedDate?.month &&
            slot['start']!.day == selectedDate?.day)
        .toList();
  }

  void _bookAppointment() async {
    if (selectedService != null && selectedStartTime != null && selectedEndTime != null) {
      bool isOverlap = salonBookings.any((booking) =>
          (booking['start']!.isBefore(selectedEndTime!) && booking['end']!.isAfter(selectedStartTime!)));

      if (isOverlap) {
        setState(() {
          isSlotAvailable = false;
        });
      } else {
        setState(() {
          isSlotAvailable = true;
          salonBookings.add({
            'start': selectedStartTime!,
            'end': selectedEndTime!,
            'service': selectedService!,
          });
          _saveAppointmentToFirebase();
          isAppointmentConfirmed = true;

          // Resetting the state to initial state
          selectedService = null;
          selectedDate = null;
          selectedStartTime = null;
          selectedEndTime = null;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Appointment booked successfully!'),
          ));
        });
      }
    }
  }

  Future<void> _saveAppointmentToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'salonId': widget.salonId,
        'service': selectedService,
        'start': selectedStartTime,
        'end': selectedEndTime,
      });
    }
  }

  List<Widget> _buildAppointmentContainers() {
    return salonBookings.map((booking) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salon: ${widget.salonName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Service: ${booking['service']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(booking['start'])}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Start Time: ${DateFormat('kk:mm').format(booking['start'])}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('End Time: ${DateFormat('kk:mm').format(booking['end'])}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReschedulePage(
                      salonId: widget.salonId,
                      salonName: widget.salonName,
                      booking: booking,
                    ),
                  ),
                );
              },
              child: const Text('Reschedule'),
            ),
          ],
        ),
      );
    }).toList();
  }
}
