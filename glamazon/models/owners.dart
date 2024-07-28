class Salon {
  String aboutUs;
  String contact;
  String email;
  String location;
  String ownerName;
  String profileImageUrl;
  String role;
  String salonName;
  String websiteUrl;
  Map<String, bool> servicesOffered;
  String workingDays;
  String workingHours;

  Salon({
    required this.aboutUs,
    required this.contact,
    required this.email,
    required this.location,
    required this.ownerName,
    required this.profileImageUrl,
    required this.role,
    required this.salonName,
    required this.websiteUrl,
    required this.servicesOffered,
    required this.workingDays,
    required this.workingHours,
  });

  // Factory constructor to create an instance from a JSON map
  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      aboutUs: json['aboutUs'],
      contact: json['contact'],
      email: json['email'],
      location: json['location'],
      ownerName: json['ownerName'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'],
      salonName: json['salonName'],
      websiteUrl: json['websiteUrl'],
      servicesOffered: Map<String, bool>.from(json['servicesOffered']),
      workingDays: json['workingDays'],
      workingHours: json['workingHours'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'aboutUs': aboutUs,
      'contact': contact,
      'email': email,
      'location': location,
      'ownerName': ownerName,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'salonName': salonName,
      'websiteUrl': websiteUrl,
      'servicesOffered': servicesOffered,
      'workingDays': workingDays,
      'workingHours': workingHours,
    };
  }
}
