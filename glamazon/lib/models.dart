import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  final String id;
  final String ownerName;
  final String profileImageUrl;
  final String salonName;
  final String location;
  final String contact;
  final String workingDays;
  final String workingHours;
  final Map<String, bool> servicesOffered;

  Owner({
    required this.id,
    required this.ownerName,
    required this.profileImageUrl,
    required this.salonName,
    required this.location,
    required this.contact,
    required this.workingDays,
    required this.workingHours,
    required this.servicesOffered,
  });

  // Factory constructor to create an instance from a JSON map
  factory Owner.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Owner(
      id: document.id,
      ownerName: data['ownerName'],
      profileImageUrl: data['profileImageUrl'],
      salonName: data['salonName'],
      location: data['location'],
      contact: data['contact'],
      workingDays: data['workingDays'],
      workingHours: data['workingHours'],
      servicesOffered: Map<String, bool>.from(data['servicesOffered'] ?? {}),
    );
  }
}
