import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glamazon/models.dart';

// Your Owner model
// class Owner {
//   final String id;
//   final String ownerName;
//   final String profileImageUrl;
//   final String salonName;
//   final String location;
//   final String contact;
//   final String workingDays;
//   final String workingHours;
//   final Map<String, bool> servicesOffered;

//   Owner({
//     required this.id,
//     required this.ownerName,
//     required this.profileImageUrl,
//     required this.salonName,
//     required this.location,
//     required this.contact,
//     required this.workingDays,
//     required this.workingHours,
//     required this.servicesOffered,
//   });

//   factory Owner.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return Owner(
//       id: document.id,
//       ownerName: data['ownerName'],
//       profileImageUrl: data['profileImageUrl'],
//       salonName: data['salonName'],
//       location: data['location'],
//       contact: data['contact'],
//       workingDays: data['workingDays'],
//       workingHours: data['workingHours'],
//       servicesOffered: Map<String, bool>.from(data['servicesOffered'] ?? {}),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInPage();
          } else {
            return BookingPage(salonId: 'your_salon_id', salonName: 'Your Salon Name');
          }
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signInAnonymously();
          },
          child: Text('Sign In Anonymously'),
        ),
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  BookingPage({required this.salonId, required this.salonName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Owner? salonOwner;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalonData();
  }

  Future<void> fetchSalonData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('owners')
          .doc(widget.salonId)
          .get();
      setState(() {
        salonOwner = Owner.fromSnapshot(snapshot);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching salon data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.salonName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : salonOwner == null
              ? Center(child: Text('Failed to load salon data'))
              : ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Services Offered:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...salonOwner!.servicesOffered.entries
                        .where((entry) => entry.value)
                        .map((entry) => ListTile(
                              title: Text(entry.key),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Implement booking logic here
                                  print('Booking ${entry.key}');
                                },
                                child: Text('Book'),
                              ),
                            ))
                        .toList(),
                  ],
                ),
    );
  }
}
