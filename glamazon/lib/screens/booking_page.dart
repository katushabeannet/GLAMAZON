import 'package:flutter/material.dart';
import 'package:glamazon/screens/reschedule_page.dart';
import 'package:intl/intl.dart';

Map<String, Duration> servicesWithDurations = {
  'Haircut': const Duration(hours: 1),
  'Manicure': const Duration(hours: 1, minutes: 30),
  'Pedicure': const Duration(hours: 1, minutes: 15),
  'Massage': const Duration(hours: 2),
};

Map<String, List<Map<String, dynamic>>> salonBookings = {
  'Salon1': [
    {
      'start': DateTime.now().add(const Duration(hours: 2)),
      'end': DateTime.now().add(const Duration(hours: 3)),
      'service': 'Haircut',
    },
    {
      'start': DateTime.now().add(const Duration(hours: 4)),
      'end': DateTime.now().add(const Duration(hours: 5)),
      'service': 'Manicure',
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
  bool isAppointmentConfirmed = false;
  final ScrollController _scrollController = ScrollController();

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
            'start': selectedStartTime!,
            'end': selectedEndTime!,
            'service': selectedService!,
          });
          salonBookings[widget.salonId] = bookings;
          isAppointmentConfirmed = true;

          // Resetting the state to initial state
          // String? confirmedService = selectedService;
          // DateTime? confirmedDate = selectedDate;
          // DateTime? confirmedStartTime = selectedStartTime;
          // DateTime? confirmedEndTime = selectedEndTime;

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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(
                salonId: widget.salonId,
                salonName: widget.salonName,
              ),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Appointment booked successfully!'),
          ));
        });
      }
    }
  }

  List<Widget> _buildAppointmentContainers() {
    List<Map<String, dynamic>> bookings = salonBookings[widget.salonId] ?? [];
    return bookings.map((booking) {
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
            Text('Service: ${booking['service']}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(booking['start']!)}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Time: ${DateFormat('kk:mm').format(booking['start']!)} - ${DateFormat('kk:mm').format(booking['end']!)}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReschedulePage(salonId: '', salonName: '',)),
                    );
                  },
                  child: const Text('Reschedule'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildDeleteConfirmationDialog(context, booking);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> booking) {
    TextEditingController reasonController = TextEditingController();
    return AlertDialog(
      title: const Text('Cancel Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Are you sure you want to cancel this appointment?'),
          const SizedBox(height: 20),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for cancellation',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Cancel Appointment'),
          onPressed: () {
            setState(() {
              salonBookings[widget.salonId]!.remove(booking);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Appointment cancelled.'),
            ));
          },
        ),
      ],
    );
  }
}

