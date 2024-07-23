import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    _salonNameController.text = 'Glamazon Salon'; // Example default data
    _ownerNameController.text = 'Enter Your Name';
    _contactController.text = '123-456-7890';
    _emailController.text = 'alinda.tracy@example.com';
    _locationController.text = '123 Beauty Street, Glamour City';
    _websiteController.text = 'https://example.com'; // Example new field data
    _aboutUsController.text =
        'Welcome to Glamazon Salon, where beauty meets excellence!'; // Example new field data
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop(); // Close the bottom sheet
                _pickImage(ImageSource.camera); // Pick image from the camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
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
          _profileImage =
              File(image.path); // Set the picked image as the profile picture
        });
      }
    } catch (e) {
      // Handle any errors that might occur during image picking
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/default.png')
                            as ImageProvider<Object>,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showImageSourceDialog,
                      // show dialog to choose image source
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: _salonNameController,
                      label: 'Salon Name',
                      hint: 'Enter Salon Name',
                      icon: Icons.business,
                    ),
                    _buildTextFormField(
                      controller: _ownerNameController,
                      label: 'Owner\'s Name',
                      hint: 'Enter Owner\'s Name',
                      icon: Icons.person,
                    ),
                    _buildTextFormField(
                      controller: _contactController,
                      label: 'Contact',
                      hint: 'Enter Contact Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextFormField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Enter Location',
                      icon: Icons.location_on,
                    ),
                    _buildTextFormField(
                      controller: _websiteController,
                      label: 'Website URL',
                      hint: 'Enter Website URL',
                      icon: Icons.web,
                      keyboardType: TextInputType.url,
                    ),
                    _buildTextFormField(
                      controller: _aboutUsController,
                      label: 'About Us',
                      hint: 'Enter About Us Description',
                      icon: Icons.info,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pop(
                            context,
                            {
                              'profileImageUrl': _profileImage?.path ??
                                  'https://example.com/profile.jpg',
                              'salonName': _salonNameController.text,
                              'location': _locationController.text,
                              'ownerName': _ownerNameController.text,
                              'contact': _contactController.text,
                              'email': _emailController.text,
                              'websiteUrl': _websiteController.text,
                              'aboutUs': _aboutUsController.text,
                            },
                          );
                        }
                      },
                      child: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFA0522D), // Sienna color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon:
              Icon(icon, color: const Color(0xFFA0522D)), // Sienna color
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: const Color(0xFFA0522D)
                    .withOpacity(0.5)), // Light Sienna color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide:
                BorderSide(color: const Color(0xFFA0522D)), // Sienna color
          ),
        ),
        cursorColor: const Color(0xFFA0522D), // Sienna color
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
