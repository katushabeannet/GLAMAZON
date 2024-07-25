import 'package:flutter/material.dart';
import 'package:glamazon/screens/profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage package

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();

  final _salonNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutUsController = TextEditingController();
  final _websiteController = TextEditingController(); // New field controller

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
          _salonNameController.text = data['salonName'] ?? '';
          _ownerNameController.text = data['ownerName'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
          _aboutUsController.text = data['aboutUs'] ?? '';
          _websiteController.text = data['websiteUrl'] ?? '';
          if (data['profileImageUrl'] != null && data['profileImageUrl']!.isNotEmpty) {
            _profileImage = File(data['profileImageUrl']!); // Assuming the URL is a local path
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
        setState(() {
          _profileImage = File(image.path); // Set the picked image as the profile picture
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String> _uploadProfileImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final profileImagesRef = storageRef.child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = profileImagesRef.putFile(image);

    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(_profileImage!);
      }

      final profileData = {
        'profileImageUrl': profileImageUrl ?? '',
        'salonName': _salonNameController.text,
        'ownerName': _ownerNameController.text,
        'contact': _contactController.text,
        'email': _emailController.text,
        'location': _locationController.text,
        'websiteUrl': _websiteController.text.isEmpty ? '' : _websiteController.text,
        'aboutUs': _aboutUsController.text,
        'role': 'salon_owner', // To distinguish between customer and salon owner
      };

      try {
        await FirebaseFirestore.instance
            .collection('owners')
            .doc(user.uid)
            .set(profileData);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFA0522D), // Sienna color
      ),
      body: Padding(
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
                        : const AssetImage('assets/images/default.png')
                            as ImageProvider<Object>,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
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
                      controller: _websiteController,
                      label: 'Website URL',
                      hint: 'Enter Website URL',
                      icon: Icons.web,
                      optional: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      controller: _aboutUsController,
                      label: 'About Us',
                      hint: 'Enter About Us',
                      icon: Icons.info,
                    ),
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
