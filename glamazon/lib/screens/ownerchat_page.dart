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
  final String userId;
  final String userName;
  final String userProfileImageUrl;
  final String ownerProfileImageUrl;

  const OwnerChatPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userProfileImageUrl,
    required this.ownerProfileImageUrl,
  });

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
          .where('userId', isEqualTo: widget.userId)
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
        'userId': widget.userId,
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
    final messages = await FirebaseFirestore.instance
        .collection('messages')
        .where('userId', isEqualTo: widget.userId)
        .get();
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
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.userProfileImageUrl.isNotEmpty
                  ? NetworkImage(widget.userProfileImageUrl)
                  : const AssetImage('assets/images/user.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
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
                        CircleAvatar(
                          backgroundImage: widget.userProfileImageUrl.isNotEmpty
                              ? NetworkImage(widget.userProfileImageUrl)
                              : const AssetImage('assets/images/user.png') as ImageProvider,
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
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: VideoPlayerWidget(url: message['video']),
                                      ),
                                    ),
                                  ],
                                  if (message['text'].isNotEmpty)
                                    Text(
                                      message['text'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              _formatTime(message['timestamp']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      if (isOwner)
                        CircleAvatar(
                          backgroundImage: widget.ownerProfileImageUrl.isNotEmpty
                              ? NetworkImage(widget.ownerProfileImageUrl)
                              : const AssetImage('assets/images/user.png') as ImageProvider,
                          radius: 20.0,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _takePhoto,
                ),
                IconButton(
                  icon: const Icon(Icons.video_library),
                  onPressed: _pickVideo,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: _recordVideo,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color hexStringToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
