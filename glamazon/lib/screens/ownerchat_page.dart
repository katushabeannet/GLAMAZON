import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class OwnerChatPage extends StatefulWidget {
  const OwnerChatPage({super.key});

  @override
  _OwnerChatPageState createState() => _OwnerChatPageState();
}

class _OwnerChatPageState extends State<OwnerChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();

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
            'userId': data['userId'] ?? '',
            'messageId': doc.id,
          });
        }
      });
    }
  }

  Future<void> _sendMessage(String text, {File? image, File? video}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final messageData = {
        'text': text,
        'image': image != null ? await _uploadFile(image) : null,
        'video': video != null ? await _uploadFile(video) : null,
        'timestamp': FieldValue.serverTimestamp(),
        'isOwner': true,
        'userId': user.uid,
      };

      await FirebaseFirestore.instance.collection('messages').add(messageData);

      _messageController.clear();
      _fetchMessages(); // Refresh messages after sending
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}');
      final uploadTask = storageReference.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
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

  Future<void> _clearAllChats() async {
    final messages = await FirebaseFirestore.instance.collection('messages').get();
    for (var doc in messages.docs) {
      await FirebaseFirestore.instance.collection('messages').doc(doc.id).delete();
    }
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: const Text('Owner Chat'),
        backgroundColor: hexStringToColor("#C0724A"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text('Are you sure you want to clear all chats?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                _clearAllChats();
              }
            },
          ),
        ],
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
                return Container(
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
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isOwner
                                    ? hexStringToColor("#089be3")
                                    : hexStringToColor("#C0724A"),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isOwner ? const Radius.circular(16) : const Radius.circular(0),
                                  bottomRight: isOwner ? const Radius.circular(0) : const Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message['image'] != null) ...[
                                    const Text(
                                      "Image",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                                      ),
                                      child: Image.network(message['image']),
                                    ),
                                  ] else if (message['video'] != null) ...[
                                    const Text(
                                      "Video",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoPlayerPage(videoUrl: message['video']),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 48.0,
                                        ),
                                      ),
                                    ),
                                  ] else if (message['text'].isNotEmpty) ...[
                                    Text(
                                      message['text'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
                      const SizedBox(width: 10.0),
                      if (isOwner)
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/salon_owner.png'),
                          radius: 20.0,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a photo'),
                              onTap: () {
                                _takePhoto();
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                _pickImage();
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
                              title: const Text('Record video'),
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

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: hexStringToColor("#C0724A"),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

Color hexStringToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
