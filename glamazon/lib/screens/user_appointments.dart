import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  _UserAppointmentsPageState createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
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
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        appointments = appointmentsSnapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'id': doc.id,
            'service': data['service'],
            'salonName': data['salonName'] ?? 'Unknown Salon',
            'date': (data['date'] as Timestamp).toDate(),
            'time': TimeOfDay(
              hour: data['time']['hour'],
              minute: data['time']['minute'],
            ),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching user appointments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('My Appointments', style: TextStyle(color: Colors.black)),
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
                    const Text(
                      'Upcoming Appointments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appointment['service'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 164, 100, 68),
                                      ),
                                    ),
                                    Text(
                                      appointment['salonName'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 121, 85, 72),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  "Date: ${DateFormat('yyyy-MM-dd').format(appointment['date'])}",
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  "Time: ${appointment['time'].format(context)}",
                                ),
                                const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
