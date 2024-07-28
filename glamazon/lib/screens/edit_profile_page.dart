import 'package:flutter/material.dart';
import 'package:glamazon/screens/profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _salonNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _workingDaysController = TextEditingController();
  final _workingHoursController = TextEditingController();

  bool isEditing = false;
  String? _profileImageUrl;
  Map<String, bool> _servicesOffered = {
    'Hair styling and Cuts': false,
    'Nails': false,
    'Spa or Massage': false,
    'Tattoo': false,
    'Facial and Makeup': false,
    'Piercing': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final profileDoc = await FirebaseFirestore.instance.collection('owners').doc(user.uid).get();
      final data = profileDoc.data();
      if (data != null) {
        setState(() {
          isEditing = true;
          _salonNameController.text = data['salonName'] ?? '';
          _ownerNameController.text = data['ownerName'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
          _workingDaysController.text = data['workingDays'] ?? 'Monday to Saturday';
          _workingHoursController.text = data['workingHours'] ?? '';
          _profileImageUrl = data['profileImageUrl'];

          if (data['servicesOffered'] != null) {
            _servicesOffered = Map<String, bool>.from(data['servicesOffered']);
          }
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera, color: Color(0xFFA0522D)), // Brown color
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop(); // Close the bottom sheet
                _pickImage(ImageSource.camera); // Pick image from the camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFFA0522D)), // Brown color
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop(); // Close the bottom sheet
                _pickImage(ImageSource.gallery); // Pick image from the gallery
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        final File imageFile = File(image.path);
        if (await imageFile.exists()) {
          print('Picked image path: ${imageFile.path}'); // Debugging line
          setState(() {
            _profileImage = imageFile; // Set the picked image as the profile picture
          });
        } else {
          throw Exception('Picked image file does not exist.');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String> _uploadProfileImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final profileImagesRef = storageRef.child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = profileImagesRef.putFile(image);

      final snapshot = await uploadTask.whenComplete(() => null);
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Uploaded image URL: $downloadUrl'); // Debugging line
        return downloadUrl;
      } else {
        final error = snapshot.state;
        throw Exception('Upload task did not complete successfully. State: $error');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not authenticated')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? profileImageUrl;
      if (_profileImage != null) {
        try {
          print('Uploading profile image...');
          profileImageUrl = await _uploadProfileImage(_profileImage!);
          print('Profile image uploaded successfully: $profileImageUrl');
        } catch (e) {
          print('Error uploading profile image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final profileData = {
        'profileImageUrl': profileImageUrl ?? _profileImageUrl ?? '',
        'salonName': _salonNameController.text,
        'ownerName': _ownerNameController.text,
        'contact': _contactController.text,
        'email': _emailController.text,
        'location': _locationController.text,
        'workingDays': _workingDaysController.text,
        'workingHours': _workingHoursController.text,
        'servicesOffered': _servicesOffered,
        'role': 'salon_owner', // To distinguish between customer and salon owner
      };

      try {
        print('Saving profile data...');
        await FirebaseFirestore.instance
            .collection('owners')
            .doc(user.uid)
            .set(profileData, SetOptions(merge: true)); // Use merge to update existing data
        print('Profile data saved successfully.');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(),
            ),
          );
        }
      } catch (e) {
        print('Error saving profile data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Register Salon'),
        backgroundColor: const Color(0xFFA0522D), // Sienna color
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/images/default.png'))
                                as ImageProvider<Object>,
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera, color: Color(0xFFA0522D)), // Changed to brown color
                        onPressed: _showImageSourceDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFormField(
                          controller: _salonNameController,
                          label: 'Salon Name',
                          hint: 'Enter Salon Name',
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _ownerNameController,
                          label: 'Owner\'s Name',
                          hint: 'Enter Owner\'s Name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _contactController,
                          label: 'Contact',
                          hint: 'Enter Contact Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _locationController,
                          label: 'Location',
                          hint: 'Enter Location',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _workingDaysController,
                          label: 'Working Days',
                          hint: 'Enter Working Days (e.g., Monday to Saturday)',
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 15),
                        _buildTextFormField(
                          controller: _workingHoursController,
                          label: 'Working Hours',
                          hint: 'Enter Working Hours (e.g., 9 AM - 6 PM)',
                          icon: Icons.access_time,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Services Offered',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._servicesOffered.keys.map((service) {
                          return CheckboxListTile(
                            title: Text(service),
                            value: _servicesOffered[service],
                            onChanged: (bool? value) {
                              setState(() {
                                _servicesOffered[service] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFA0522D), // Sienna color
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFA0522D)), // Brown color for the icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: const Color(0xFFA0522D), width: 1.5), // Brown color for the border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: const Color(0xFFA0522D), width: 1.5), // Brown color for the focused border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: const Color(0xFFA0522D), width: 1.5), // Brown color for the enabled border
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (!optional) {
            return 'Please enter $label';
          }
        }
        return null;
      },
    );
  }
}
