import 'package:flutter/material.dart';
import 'package:glamazon/screens/notification-deatails.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  final String salonOwnerProfileImage =
      'assets/images/dp.jpg'; // Placeholder profile image

  void _sendMessage(String text, {File? image, File? video}) {
    setState(() {
      _messages.add({
        'text': text,
        'image': image,
        'video': video,
        'timestamp': DateTime.now(),
        'isOwner': true, // Indicate that the message is from the salon owner
      });
    });
    _messageController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final resizedImage = await _resizeImage(File(pickedFile.path));
      _sendMessage('', image: resizedImage);
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final resizedImage = await _resizeImage(File(pickedFile.path));
      _sendMessage('', image: resizedImage);
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMessage('', video: File(pickedFile.path));
    }
  }

  Future<void> _recordVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      _sendMessage('', video: File(pickedFile.path));
    }
  }

  Future<File> _resizeImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      final resizedImage = img.copyResize(image,
          width: 400); // Resize to width 400, maintaining aspect ratio
      final resizedImageBytes = img.encodeJpg(resizedImage);

      final resizedImageFile = File(imageFile.path)
        ..writeAsBytesSync(resizedImageBytes);

      return resizedImageFile;
    } else {
      return imageFile;
    }
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Text('Chat Room'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isOwner = message['isOwner'];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(isOwner
                            ? salonOwnerProfileImage
                            : 'assets/images/user.png'), // Placeholder user profile image
                        radius: 20.0,
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isOwner
                                    ? hexStringToColor("#C0724A")
                                    : hexStringToColor("#089be3"),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  message['text'].isNotEmpty
                                      ? Text(
                                          message['text'],
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      : message['image'] != null
                                          ? Image.file(message['image'])
                                          : message['video'] != null
                                              ? Column(
                                                  children: [
                                                    Icon(Icons.videocam,
                                                        color: Colors.white),
                                                    Text(
                                                      'Video Message',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox.shrink(),
                                  SizedBox(height: 5.0),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      _formatTime(message['timestamp']),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Pick from gallery'),
                                onTap: () {
                                  _pickImage();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_camera),
                                title: Text('Take a photo'),
                                onTap: () {
                                  _takePhoto();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  color: hexStringToColor("#089be3"),
                ),
                IconButton(
                  icon: Icon(Icons.videocam),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.video_library),
                                title: Text('Pick from gallery'),
                                onTap: () {
                                  _pickVideo();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.videocam),
                                title: Text('Record a video'),
                                onTap: () {
                                  _recordVideo();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  color: hexStringToColor("#089be3"),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                  color: hexStringToColor("#C0724A"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
