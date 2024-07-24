import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Dummy Data for Services, Durations, and Bookings
Map<String, Duration> servicesWithDurations = {
  'Haircut': Duration(hours: 1),
  'Manicure': Duration(hours: 1, minutes: 30),
  'Pedicure': Duration(hours: 1, minutes: 15),
  'Massage': Duration(hours: 2),
};

Map<String, List<Map<String, dynamic>>> salonBookings = {
  'Salon1': [
    {
      'service': 'Haircut',
      'start': DateTime.now().add(Duration(hours: 2)),
      'end': DateTime.now().add(Duration(hours: 3)),
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
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Book Appointment at ${widget.salonName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedService,
              hint: Text('Select a Service'),
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            if (selectedDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Taken Slots:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ..._getTakenSlots().map((slot) => Text(
                      '${DateFormat('HH:mm').format(slot['start'] as DateTime)} - ${DateFormat('HH:mm').format(slot['end'] as DateTime)}')).toList(),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(selectedStartTime == null
                        ? 'Select Start Time'
                        : DateFormat('kk:mm').format(selectedStartTime!)),
                    trailing: Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                  if (selectedStartTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'End Time: ${DateFormat('kk:mm').format(selectedEndTime!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookAppointment,
              child: Text('Confirm Appointment'),
            ),
            if (!isSlotAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Selected time slot is already taken. Please choose another time.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToReschedulePage,
              child: Text('Reschedule Appointment'),
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
    List<Map<String, dynamic>> takenSlots = salonBookings[widget.salonId] ?? [];
    return takenSlots
        .where((slot) =>
            slot['start']!.year == selectedDate?.year &&
            slot['start']!.month == selectedDate?.month &&
            slot['start']!.day == selectedDate?.day)
        .toList();
  }

  void _bookAppointment() {
    if (selectedService != null && selectedStartTime != null && selectedEndTime != null) {
      List<Map<String, dynamic>> bookings = salonBookings[widget.salonId] ?? [];
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
            'service': selectedService!,
            'start': selectedStartTime!,
            'end': selectedEndTime!,
          });
          salonBookings[widget.salonId] = bookings;
        });
        // Navigate to a success page or show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment booked successfully!'),
        ));
      }
    }
  }

  void _navigateToReschedulePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReschedulePage(salonId: widget.salonId, salonName: widget.salonName),
      ),
    );
  }
}

class ReschedulePage extends StatefulWidget {
  final String salonId;
  final String salonName;

  ReschedulePage({required this.salonId, required this.salonName});

  @override
  _ReschedulePageState createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  Map<String, dynamic>? existingAppointment;
  DateTime? newSelectedDate;
  DateTime? newSelectedStartTime;
  DateTime? newSelectedEndTime;
  TextEditingController rescheduleReasonController = TextEditingController();
  bool isSlotAvailable = true;

  @override
  void initState() {
    super.initState();
    existingAppointment = salonBookings[widget.salonId]?.first; // Assume one appointment per user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reschedule Appointment at ${widget.salonName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (existingAppointment != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Appointment:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${existingAppointment!['service']} - ${DateFormat('yyyy-MM-dd HH:mm').format(existingAppointment!['start'] as DateTime)} to ${DateFormat('HH:mm').format(existingAppointment!['end'] as DateTime)}',
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(newSelectedDate == null
                        ? 'Select New Date'
                        : DateFormat('yyyy-MM-dd').format(newSelectedDate!)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: _selectNewDate,
                  ),
                  if (newSelectedDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Taken Slots:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ..._getTakenSlots().map((slot) => Text(
                            '${DateFormat('HH:mm').format(slot['start'] as DateTime)} - ${DateFormat('HH:mm').format(slot['end'] as DateTime)}')).toList(),
                        SizedBox(height: 20),
                        ListTile(
                          title: Text(newSelectedStartTime == null
                              ? 'Select New Start Time'
                              : DateFormat('kk:mm').format(newSelectedStartTime!)),
                          trailing: Icon(Icons.access_time),
                          onTap: _selectNewTime,
                        ),
                        if (newSelectedStartTime != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'End Time: ${DateFormat('kk:mm').format(newSelectedEndTime!)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 20),
                  TextField(
                    controller: rescheduleReasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for Rescheduling',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _rescheduleAppointment,
                    child: Text('Confirm Reschedule'),
                  ),
                  if (!isSlotAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Selected time slot is already taken. Please choose another time.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectNewDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        newSelectedDate = pickedDate;
        newSelectedStartTime = null;
        newSelectedEndTime = null;
      });
    }
  }

  Future<void> _selectNewTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && newSelectedDate != null && existingAppointment != null) {
      setState(() {
        newSelectedStartTime = DateTime(
          newSelectedDate!.year,
          newSelectedDate!.month,
          newSelectedDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        String service = existingAppointment!['service']!;
        newSelectedEndTime = newSelectedStartTime!.add(servicesWithDurations[service]!);
      });
    }
  }

  List<Map<String, dynamic>> _getTakenSlots() {
    List<Map<String, dynamic>> takenSlots = salonBookings[widget.salonId] ?? [];
    return takenSlots
        .where((slot) =>
            slot['start']!.year == newSelectedDate?.year &&
            slot['start']!.month == newSelectedDate?.month &&
            slot['start']!.day == newSelectedDate?.day)
        .toList();
  }

  void _rescheduleAppointment() {
    if (newSelectedDate != null &&
        newSelectedStartTime != null &&
        newSelectedEndTime != null &&
        rescheduleReasonController.text.isNotEmpty) {
      List<Map<String, dynamic>> bookings = salonBookings[widget.salonId] ?? [];
      bool isOverlap = bookings.any((booking) =>
          (booking['start']!.isBefore(newSelectedEndTime!) && booking['end']!.isAfter(newSelectedStartTime!)) &&
          booking != existingAppointment);

      if (isOverlap) {
        setState(() {
          isSlotAvailable = false;
        });
      } else {
        setState(() {
          isSlotAvailable = true;
          bookings.remove(existingAppointment);
          bookings.add({
            'service': existingAppointment!['service']!,
            'start': newSelectedStartTime!,
            'end': newSelectedEndTime!,
          });
          salonBookings[widget.salonId] = bookings;
        });
        // Navigate to a success page or show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment rescheduled successfully!'),
        ));
        Navigator.pop(context);
      }
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: BookingPage(salonId: 'Salon1', salonName: 'Elegant Hair Salon'),
  ));
}
