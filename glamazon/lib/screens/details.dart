import 'package:flutter/material.dart';
import 'package:glamazon/screens/chat-page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:glamazon/screens/auto_image_slider.dart';

class SalonDetails extends StatefulWidget {
  const SalonDetails({super.key});

  @override
  _SalonDetailsPageState createState() => _SalonDetailsPageState();
}

class _SalonDetailsPageState extends State<SalonDetails> {
  final List<Map<String, String>> galleryItems = [];
  String salonName = '';
  String? profileImageUrl;
  String ownerName = '';
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchSalonDetails();
    _fetchGalleryItems();
  }

  Future<void> _fetchSalonDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profileDoc = await FirebaseFirestore.instance.collection('owners').doc(user.uid).get();
      final data = profileDoc.data();
      if (data != null) {
        setState(() {
          salonName = data['salonName'] ?? 'Salon Name';
          profileImageUrl = data['profileImageUrl'];
          ownerName = data['ownerName'] ?? 'Owner Name';
        });
      }
    }
  }

  Future<void> _fetchGalleryItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final gallerySnapshot = await FirebaseFirestore.instance.collection('owners').doc(user.uid).collection('gallery').get();
        setState(() {
          galleryItems.clear();
          for (var doc in gallerySnapshot.docs) {
            galleryItems.add({'imagePath': doc['url'], 'name': doc['name']});
          }
        });
      } catch (e) {
        print('Error fetching gallery items: $e');
      }
    }
  }

  Future<void> _pickMedia() async {
    final XFile? media = await picker.pickImage(source: ImageSource.gallery);
    if (media != null) {
      String fileName = media.name;
      String filePath = 'gallery/${FirebaseAuth.instance.currentUser!.uid}/$fileName';
      File file = File(media.path);

      try {
        await FirebaseStorage.instance.ref(filePath).putFile(file);
        String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

        await FirebaseFirestore.instance.collection('owners').doc(FirebaseAuth.instance.currentUser!.uid).collection('gallery').add({
          'url': downloadUrl,
          'name': fileName
        });

        setState(() {
          galleryItems.add({'imagePath': downloadUrl, 'name': fileName});
        });
      } catch (e) {
        print('Error uploading media: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('My Gallery', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF882D17), // Dark Sienna as base color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                        ? Image.network(
                            profileImageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        salonName,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _pickMedia,
                    child: Column(
                      children: const [
                        Icon(Icons.add_a_photo, color: Color(0xFFAA4A30)),
                        SizedBox(height: 4),
                        Text(
                          'Add a post',
                          style: TextStyle(color: Color(0xFFAA4A30)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildGallery(galleryItems),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFAA4A30),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white, // Darker Sienna shade
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.white, // Darker Sienna shade
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyImageSlider()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          }
        },
      ),
    );
  }

  Widget buildGallery(List<Map<String, String>> galleryItems) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: galleryItems.map((item) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: item['imagePath']!.endsWith('.mp4')
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoWidget(videoFile: File(item['imagePath']!)),
                      )
                    : Image.network(
                        item['imagePath']!,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class VideoWidget extends StatelessWidget {
  final File videoFile;

  const VideoWidget({required this.videoFile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add your video player implementation here
    // For example, using the video_player package
    return Container();
  }
}
