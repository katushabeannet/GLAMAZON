import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Dummy Data for Services, Durations, and Bookings
Map<String, Duration> servicesWithDurations = {
  'Haircut': const Duration(hours: 1),
  'Manicure': const Duration(hours: 1, minutes: 30),
  'Pedicure': const Duration(hours: 1, minutes: 15),
  'Massage': const Duration(hours: 2),
};

Map<String, List<Map<String, DateTime>>> salonBookings = {
  'Salon1': [
    {
      'start': DateTime.now().add(const Duration(hours: 2)),
      'end': DateTime.now().add(const Duration(hours: 3)),
    },
    {
      'start': DateTime.now().add(const Duration(hours: 4)),
      'end': DateTime.now().add(const Duration(hours: 5)),
    },
  ],
};

class BookingPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  BookingPage({required this.salonId, required this.salonName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedService;
  DateTime? selectedDate;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  bool isSlotAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book an Appointment at ${widget.salonName}'),
      ),
      body: Padding(
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
                  selectedStartTime = null; // Reset the start time when a new service is picked
                  selectedEndTime = null; // Reset the end time when a new service is picked
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
        selectedStartTime = null; // Reset the start time when a new date is picked
        selectedEndTime = null; // Reset the end time when a new date is picked
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

  List<Map<String, DateTime>> _getTakenSlots() {
    List<Map<String, DateTime>> takenSlots = salonBookings[widget.salonId] ?? [];
    return takenSlots
        .where((slot) =>
            slot['start']!.year == selectedDate?.year &&
            slot['start']!.month == selectedDate?.month &&
            slot['start']!.day == selectedDate?.day)
        .toList();
  }

  void _bookAppointment() {
    if (selectedService != null && selectedStartTime != null && selectedEndTime != null) {
      List<Map<String, DateTime>> bookings = salonBookings[widget.salonId] ?? [];
      bool isOverlap = bookings.any((booking) =>
          (booking['start']!.isBefore(selectedEndTime!) && booking['end']!.isAfter(selectedStartTime!)));

      if (isOverlap) {
        setState(() {
          isSlotAvailable = false;
        });
      } else {
        setState(() {
          isSlotAvailable = true;
          bookings.add({
            'start': selectedStartTime!,
            'end': selectedEndTime!,
          });
          salonBookings[widget.salonId] = bookings;
        });
        // Navigate to a success page or show a success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Appointment booked successfully!'),
        ));
      }
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: BookingPage(salonId: 'Salon1', salonName: 'Elegant Hair Salon'),
  ));
}
