import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key});

  @override
  _UserChatPageState createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  final String salonOwnerProfileImage = 'assets/images/dp.jpg'; // Placeholder salon owner profile image

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _messages.clear();
        for (var doc in messagesSnapshot.docs) {
          final data = doc.data();
          _messages.add({
            'text': data['text'],
            'image': data['image'],
            'video': data['video'],
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
            'isOwner': data['isOwner'] ?? false,
            'userId': data['userId'],
            'messageId': doc.id,
            'replyToMessageId': data['replyToMessageId'],
          });
        }
      });
    }
  }

  Future<void> _sendMessage(String text, {File? image, File? video, String? replyToMessageId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final messageData = {
        'text': text,
        'image': image != null ? await _uploadFile(image) : null,
        'video': video != null ? await _uploadFile(video) : null,
        'timestamp': FieldValue.serverTimestamp(),
        'isOwner': false,
        'userId': user.uid,
        'replyToMessageId': replyToMessageId,
      };

      await FirebaseFirestore.instance.collection('messages').add(messageData);

      _messageController.clear();
      _fetchMessages(); // Refresh messages after sending
    }
  }

  Future<String?> _uploadFile(File file) async {
    // Implement file upload functionality here
    return null;
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
      final resizedImage = img.copyResize(image, width: 400);
      final resizedImageBytes = img.encodeJpg(resizedImage);

      final resizedImageFile = File(imageFile.path)..writeAsBytesSync(resizedImageBytes);

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
        title: const Text('User Chat Room'),
        backgroundColor: hexStringToColor("#C0724A"), // Matching color
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isOwner = message['isOwner'];
                return GestureDetector(
                  onLongPress: () {
                    // Handle reply message logic here
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Reply to message'),
                          content: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your reply',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                final replyText = _messageController.text.trim();
                                if (replyText.isNotEmpty) {
                                  _sendMessage(replyText, replyToMessageId: message['messageId']);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Send'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isOwner)
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user.png'),
                            radius: 20.0,
                          ),
                        if (!isOwner)
                          const SizedBox(width: 10.0),
                        if (isOwner)
                          const SizedBox(width: 10.0),
                        if (isOwner)
                          CircleAvatar(
                            backgroundImage: AssetImage(salonOwnerProfileImage),
                            radius: 20.0,
                          ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: isOwner
                                      ? hexStringToColor("#089be3")
                                      : hexStringToColor("#C0724A"),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    message['text'].isNotEmpty
                                        ? Text(
                                            message['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        : message['image'] != null
                                            ? Image.network(message['image'])
                                            : message['video'] != null
                                                ? const Column(
                                                    children: [
                                                      Icon(Icons.videocam, color: Colors.white),
                                                      Text(
                                                        'Video Message',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox.shrink(),
                                    if (message['replyToMessageId'] != null)
                                      FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('messages')
                                            .doc(message['replyToMessageId'])
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          }
                                          if (snapshot.hasData && snapshot.data != null) {
                                            final replyData =
                                                snapshot.data!.data() as Map<String, dynamic>;
                                            return Container(
                                              margin: const EdgeInsets.only(top: 5.0),
                                              padding: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                replyData['text'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                _formatTime(message['timestamp']),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOwner) const SizedBox(width: 10.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Pick from gallery'),
                              onTap: () {
                                _pickImage();
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a photo'),
                              onTap: () {
                                _takePhoto();
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.video_library),
                              title: const Text('Pick video from gallery'),
                              onTap: () {
                                _pickVideo();
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.videocam),
                              title: const Text('Record a video'),
                              onTap: () {
                                _recordVideo();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final messageText = _messageController.text.trim();
                    if (messageText.isNotEmpty) {
                      _sendMessage(messageText);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  return Color(int.parse(hexColor, radix: 16));
}
