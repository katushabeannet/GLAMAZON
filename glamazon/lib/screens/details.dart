import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:glamazon/screens/auto_image_slider.dart';
import 'package:glamazon/screens/booking_page.dart';
import 'package:glamazon/screens/chat_room_page.dart';

class SalonDetails extends StatefulWidget {
  const SalonDetails({super.key});

  @override
  _SalonDetailsPageState createState() => _SalonDetailsPageState();
}

class _SalonDetailsPageState extends State<SalonDetails> {
  final List<Map<String, String>> galleryItems = [];

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickImage(source: ImageSource.gallery);

    if (media != null) {
      setState(() {
        galleryItems.add({'imagePath': media.path, 'name': 'New Media'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Glamazon', style: TextStyle(color: Colors.white)),
            const Icon(Icons.person, color: Colors.white),
          ],
        ),
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/images/spa.jpeg'), // Replace with your image asset
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Salon Name',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  BookingPage(salonId: '', salonName: '',)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAA4A30), // Sienna color
                        ),
                        child: const Text('Book Now',
                            style: TextStyle(color: Colors.white)),
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
                      children: [
                        const Icon(Icons.add_a_photo, color: Color(0xFFAA4A30)),
                        const SizedBox(height: 4),
                        const Text(
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
              MaterialPageRoute(builder: (context) =>  ChatRoomPage()),
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
                    : Image.file(
                        File(item['imagePath']!),
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
