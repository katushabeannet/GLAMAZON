import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  const BookingPage({super.key, required this.salonId, required this.salonName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<String> services = [];
  String? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchAppointments();
  }

  Future<void> _fetchServices() async {
    setState(() {
      isLoading = true;
    });
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading = true;
    });
    try {
      var appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .get();

      setState(() {
        appointments = appointmentsSnapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'id': doc.id,
            'service': data['service'],
            'date': (data['date'] as Timestamp).toDate(),
            'time': TimeOfDay(
              hour: data['time']['hour'],
              minute: data['time']['minute'],
            ),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Future<void> _submitBooking() async {
    if (selectedService != null) {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('appointments').add({
          'salonId': widget.salonId,
          'service': selectedService,
          'date': Timestamp.fromDate(selectedDate),
          'time': {
            'hour': selectedTime.hour,
            'minute': selectedTime.minute,
          },
        });
        _fetchAppointments();
      } catch (e) {
        print('Error booking appointment: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAppointment(String id) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(id).delete();
      _fetchAppointments();
    } catch (e) {
      print('Error deleting appointment: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _rescheduleAppointment(String id, DateTime newDate, TimeOfDay newTime) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(id).update({
        'date': Timestamp.fromDate(newDate),
        'time': {
          'hour': newTime.hour,
          'minute': newTime.minute,
        },
      });
      _fetchAppointments();
    } catch (e) {
      print('Error rescheduling appointment: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRescheduleDialog(String id, DateTime currentDate, TimeOfDay currentTime) {
    DateTime newDate = currentDate;
    TimeOfDay newTime = currentTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reschedule Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Date: ${DateFormat('yyyy-MM-dd').format(newDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != newDate) {
                    setState(() {
                      newDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text("Time: ${newTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: newTime,
                  );
                  if (picked != null && picked != newTime) {
                    setState(() {
                      newTime = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rescheduleAppointment(id, newDate, newTime);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content: const Text('Are you sure you want to delete this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAppointment(id);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Book at ${widget.salonName}', style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(179, 181, 81, 31),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 16.0),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    ListTile(
                      title: Text("Time: ${selectedTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 164, 100, 68),
                      ),
                      child: const Text('Submit Booking', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Appointments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return Card(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Color.fromARGB(255, 164, 100, 68),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment['service'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 164, 100, 68),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  "Date: ${DateFormat('yyyy-MM-dd').format(appointment['date'])}",
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  "Time: ${appointment['time'].format(context)}",
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => _showRescheduleDialog(
                                        appointment['id'],
                                        appointment['date'],
                                        appointment['time'],
                                      ),
                                      child: const Text('Reschedule'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmationDialog(appointment['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
