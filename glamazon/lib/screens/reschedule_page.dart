import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReschedulePage extends StatefulWidget {
  final String salonId;
  final String salonName;
  final Map<String, dynamic> booking;

  const ReschedulePage({super.key, 
    required this.salonId,
    required this.salonName,
    required this.booking,
  });

  @override
  _ReschedulePageState createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime? newStartDate;
  DateTime? newStartTime;
  DateTime? newEndTime;

  @override
  void initState() {
    super.initState();
    newStartDate = widget.booking['start'];
    newStartTime = widget.booking['start'];
    newEndTime = widget.booking['end'];
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(newStartDate == null
                  ? 'Select New Date'
                  : DateFormat('yyyy-MM-dd').format(newStartDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectNewDate,
            ),
            if (newStartDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(newStartTime == null
                        ? 'Select New Start Time'
                        : DateFormat('kk:mm').format(newStartTime!)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectNewTime,
                  ),
                  if (newStartTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'End Time: ${DateFormat('kk:mm').format(newEndTime!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rescheduleAppointment,
              child: const Text('Confirm Reschedule'),
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
        newStartDate = pickedDate;
        newStartTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          newStartTime!.hour,
          newStartTime!.minute,
        );
        newEndTime = newStartTime!.add(widget.booking['duration']);
      });
    }
  }

  Future<void> _selectNewTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && newStartDate != null) {
      setState(() {
        newStartTime = DateTime(
          newStartDate!.year,
          newStartDate!.month,
          newStartDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        newEndTime = newStartTime!.add(widget.booking['duration']);
      });
    }
  }

  void _rescheduleAppointment() {
    // Add logic to update the appointment in Firebase
    Navigator.pop(context);
  }
}
