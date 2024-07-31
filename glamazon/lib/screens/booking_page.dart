import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        print('No user is logged in');
        return;
      }

      var appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .where('userId', isEqualTo: user.uid) // Ensure this field exists in the appointments collection
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

  Future<void> _submitBooking() async {
    if (selectedService != null) {
      setState(() {
        isLoading = true;
      });
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Handle the case where the user is not logged in
          print('No user is logged in');
          return;
        }

        var userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          var userData = userSnapshot.data()!;
          var userName = userData['username'];
          var userPhone = userData['phone'];

          await FirebaseFirestore.instance.collection('appointments').add({
            'salonId': widget.salonId,
            'salonName': widget.salonName, // Include salonName
            'service': selectedService,
            'date': Timestamp.fromDate(selectedDate),
            'time': {
              'hour': selectedTime.hour,
              'minute': selectedTime.minute,
            },
            'userId': user.uid, // Include userId for mapping
            'userName': userName,
            'userPhone': userPhone,
          });
          _fetchAppointments();
        }
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
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Color.fromARGB(255, 255, 219, 59)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Reschedule', style: TextStyle(color: Color.fromARGB(255, 233, 160, 133))),
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
                      onTap: () async {
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
                      },
                    ),
                    ListTile(
                      title: Text("Time: ${selectedTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(179, 181, 81, 31), // Change the button color here
                      ),
                      child: const Text('Book Appointment'),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Your Appointments:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    ...appointments.map((appointment) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.transparent, // Set background to transparent
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color.fromARGB(179, 181, 81, 31), width: 1), // Thin golden border
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service: ${appointment['service']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA0522D), // Sienna color
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text('Date: ${DateFormat('yyyy-MM-dd').format(appointment['date'])}'),
                              const SizedBox(height: 4.0),
                              Text('Time: ${appointment['time'].format(context)}'),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showRescheduleDialog(
                                        appointment['id'],
                                        appointment['date'],
                                        appointment['time'],
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      side: const BorderSide(color: Color.fromARGB(179, 181, 81, 31)), // Thin golden border
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text('Reschedule'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(appointment['id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
