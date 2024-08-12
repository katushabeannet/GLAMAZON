// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:glamazon/models.dart';
// import 'package:glamazon/screens/appointments_page.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:video_player/video_player.dart';

// class ChatPage extends StatefulWidget {
//   final Owner salon;

//   const ChatPage({required this.salon, Key? key}) : super(key: key);

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   final ImagePicker _picker = ImagePicker();
//   String? _userName;
//   String? _userProfileImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserInfo();
//     _fetchMessages();
//   }

//   Future<void> _fetchUserInfo() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       if (userSnapshot.exists) {
//         setState(() {
//           _userName = userSnapshot.data()?['username'];
//           _userProfileImageUrl = userSnapshot.data()?['profile_picture'];
//         });
//       }
//     }
//   }

//   Future<void> _fetchMessages() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final messagesSnapshot = await FirebaseFirestore.instance
//             .collection('messages')
//             .where('salonId', isEqualTo: widget.salon.id)
//             .where('userId', isEqualTo: user.uid)
//             .orderBy('timestamp', descending: true)
//             .get();

//         setState(() {
//           _messages.clear();
//           for (var doc in messagesSnapshot.docs) {
//             final data = doc.data();
//             _messages.add({
//               'text': data['text'] ?? '',
//               'image': data['image'],
//               'video': data['video'],
//               'timestamp': (data['timestamp'] as Timestamp).toDate(),
//               'isOwner': data['isOwner'] ?? false,
//               'userId': data['userId'] ?? '',
//               'userName': data['userName'] ?? '',
//               'userProfileImageUrl': data['userProfileImageUrl'] ?? '',
//               'messageId': doc.id,
//             });
//           }
//         });
//       } catch (e) {
//         print('Error fetching messages: $e');
//       }
//     }
//   }

//   Future<void> _sendMessage(String text, {File? image, File? video}) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final messageData = {
//         'text': text,
//         'image': image != null ? await _uploadFile(image) : null,
//         'video': video != null ? await _uploadFile(video) : null,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isOwner': false,
//         'userId': user.uid,
//         'userName': _userName,
//         'userProfileImageUrl': _userProfileImageUrl,
//         'salonId': widget.salon.id,
//       };

//       try {
//         await FirebaseFirestore.instance.collection('messages').add(messageData);
//       } catch (e) {
//         print('Error sending message: $e');
//       }

//       _messageController.clear();
//       _fetchMessages(); // Refresh messages after sending
//     }
//   }

//   Future<String?> _uploadFile(File file) async {
//     try {
//       final storageReference = FirebaseStorage.instance
//           .ref()
//           .child('uploads/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}');
//       final uploadTask = storageReference.putFile(file);

//       final snapshot = await uploadTask.whenComplete(() {});
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading file: $e');
//       return null;
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final resizedImage = await _resizeImage(File(pickedFile.path));
//       _sendMessage('', image: resizedImage);
//     }
//   }

//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       final resizedImage = await _resizeImage(File(pickedFile.path));
//       _sendMessage('', image: resizedImage);
//     }
//   }

//   Future<void> _pickVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       _sendMessage('', video: File(pickedFile.path));
//     }
//   }

//   Future<void> _recordVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
//     if (pickedFile != null) {
//       _sendMessage('', video: File(pickedFile.path));
//     }
//   }

//   Future<File> _resizeImage(File imageFile) async {
//     final imageBytes = await imageFile.readAsBytes();
//     final image = img.decodeImage(imageBytes);

//     if (image != null) {
//       final resizedImage = img.copyResize(image, width: 400);
//       final resizedImageBytes = img.encodeJpg(resizedImage);

//       final resizedImageFile = File(imageFile.path)..writeAsBytesSync(resizedImageBytes);

//       return resizedImageFile;
//     } else {
//       return imageFile;
//     }
//   }

//   String _formatTime(DateTime timestamp) {
//     return DateFormat('hh:mm a').format(timestamp);
//   }

//   Future<VideoPlayerController> _initializeVideoPlayer(String videoUrl) async {
//     final controller = VideoPlayerController.network(videoUrl);
//     await controller.initialize();
//     await controller.setLooping(true);
//     await controller.play();
//     return controller;
//   }

//   Future<void> _clearAllChats() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final messagesSnapshot = await FirebaseFirestore.instance
//           .collection('messages')
//           .where('salonId', isEqualTo: widget.salon.id)
//           .where('userId', isEqualTo: user.uid)
//           .get();

//       for (var doc in messagesSnapshot.docs) {
//         await FirebaseFirestore.instance.collection('messages').doc(doc.id).delete();
//       }

//       _fetchMessages(); // Refresh messages after clearing
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 248, 236, 220),
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.salon.profileImageUrl.isNotEmpty
//                   ? NetworkImage(widget.salon.profileImageUrl)
//                   : const AssetImage('assets/images/user.png') as ImageProvider,
//             ),
//             const SizedBox(width: 10),
//             Text(widget.salon.salonName),
//           ],
//         ),
//         backgroundColor: hexStringToColor("#C0724A"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text('Clear Chat'),
//                     content: const Text('Are you sure you want to clear all chats?'),
//                     actions: [
//                       TextButton(
//                         child: const Text('Cancel'),
//                         onPressed: () => Navigator.of(context).pop(false),
//                       ),
//                       TextButton(
//                         child: const Text('Clear'),
//                         onPressed: () => Navigator.of(context).pop(true),
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (confirm == true) {
//                 _clearAllChats();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isCurrentUser = message['userId'] == FirebaseAuth.instance.currentUser?.uid;

//                 return Container(
//                   margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (!isCurrentUser) ...[
//                         CircleAvatar(
//                           backgroundImage: message['userProfileImageUrl'].isNotEmpty
//                               ? NetworkImage(message['userProfileImageUrl'])
//                               : const AssetImage('assets/images/user.png') as ImageProvider,
//                           radius: 20.0,
//                         ),
//                         const SizedBox(width: 8.0),
//                       ],
//                       Flexible(
//                         child: Column(
//                           crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                           children: [
//                             if (message['text'] != null && message['text'].isNotEmpty)
//                               Container(
//                                 padding: const EdgeInsets.all(12.0),
//                                 decoration: BoxDecoration(
//                                   color: isCurrentUser ? hexStringToColor("#C0724A") : Colors.grey[300],
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Text(
//                                   message['text'],
//                                   style: TextStyle(
//                                     color: isCurrentUser ? Colors.white : Colors.black87,
//                                   ),
//                                 ),
//                               ),
//                             if (message['image'] != null)
//                               Container(
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   color: isCurrentUser ? hexStringToColor("#C0724A") : Colors.grey[300],
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Image.network(message['image']),
//                               ),
//                             if (message['video'] != null)
//                               FutureBuilder<VideoPlayerController>(
//                                 future: _initializeVideoPlayer(message['video']),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
//                                     return AspectRatio(
//                                       aspectRatio: snapshot.data!.value.aspectRatio,
//                                       child: VideoPlayer(snapshot.data!),
//                                     );
//                                   } else {
//                                     return CircularProgressIndicator();
//                                   }
//                                 },
//                               ),
//                             Text(
//                               _formatTime(message['timestamp']),
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (isCurrentUser) ...[
//                         const SizedBox(width: 8.0),
//                         CircleAvatar(
//                           backgroundImage: message['userProfileImageUrl'].isNotEmpty
//                               ? NetworkImage(message['userProfileImageUrl'])
//                               : const AssetImage('assets/images/user.png') as ImageProvider,
//                           radius: 20.0,
//                         ),
//                       ],
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.photo),
//                   onPressed: _pickImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.camera),
//                   onPressed: _takePhoto,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.videocam),
//                   onPressed: _pickVideo,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.video_call),
//                   onPressed: _recordVideo,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     final text = _messageController.text.trim();
//                     if (text.isNotEmpty) {
//                       _sendMessage(text);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:glamazon/screens/ownerchat_page.dart';

// class OwnerChatMainPage extends StatefulWidget {
//   @override
//   _OwnerChatMainPageState createState() => _OwnerChatMainPageState();
// }

// class _OwnerChatMainPageState extends State<OwnerChatMainPage> {
//   final List<Map<String, dynamic>> _users = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final messagesSnapshot = await FirebaseFirestore.instance
//           .collection('messages')
//           .where('isOwner', isEqualTo: false)
//           .get();

//       final userIds = messagesSnapshot.docs
//           .map((doc) => doc.data()['userId'] as String)
//           .toSet()
//           .toList();

//       final usersSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where(FieldPath.documentId, whereIn: userIds)
//           .get();

//       setState(() {
//         _users.clear();
//         for (var doc in usersSnapshot.docs) {
//           final data = doc.data();
//           _users.add({
//             'userId': doc.id,
//             'username': data['username'],
//             'profile_picture': data['profile_picture'],
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 248, 236, 220),
//       appBar: AppBar(
//         title: const Text('Owner Chat Main Page'),
//         backgroundColor: hexStringToColor("#C0724A"),
//       ),
//       body: ListView.builder(
//         itemCount: _users.length,
//         itemBuilder: (context, index) {
//           final user = _users[index];
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage: user['profile_picture'] != null
//                   ? NetworkImage(user['profile_picture'])
//                   : const AssetImage('assets/images/user.png') as ImageProvider,
//             ),
//             title: Text(user['username']),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => OwnerChatPage(
//                     userId: user['userId'],
//                     userName: user['username'],
//                     userProfileImageUrl: user['profile_picture'],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// Color hexStringToColor(String hexColor) {
//   final color = hexColor.replaceAll("#", "");
//   return Color(int.parse("FF$color", radix: 16));
// }





// import 'package:firebase_messaging/firebase_messaging.dart';

// class AppointmentsPage extends StatelessWidget {
//   const AppointmentsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => NotificationDetailsPage(
//             appointmentId: message.data['appointmentId'],
//           ),
//         ),
//       );
//     });

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 248, 236, 220),
//       appBar: AppBar(
//         title: const Text('Appointments'),
//         backgroundColor: hexStringToColor("#C0724A"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: _fetchAppointments(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return const Center(child: Text('No appointments found.'));
//             }

//             final appointments = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

//             return ListView.builder(
//               itemCount: appointments.length,
//               itemBuilder: (context, index) {
//                 final appointment = appointments[index];
//                 final requestedTime = appointment['time'];
//                 DateTime appointmentDateTime = appointment['date'] != null
//                     ? (appointment['date'] as Timestamp).toDate()
//                     : DateTime.now();

//                 return FutureBuilder<DocumentSnapshot>(
//                   future: _fetchUserDetails(appointment['userId']),
//                   builder: (context, userSnapshot) {
//                     if (userSnapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (userSnapshot.hasError) {
//                       return Center(child: Text('Error: ${userSnapshot.error}'));
//                     }
//                     if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
//                       return const Center(child: Text('User details not found.'));
//                     }

//                     final userData = userSnapshot.data!.data() as Map<String, dynamic>;
//                     final userName = userData['username'] ?? 'Unknown User';
//                     final contactNumber = userData['phone'] ?? 'N/A';

//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Card(
//                         elevation: 4.0,
//                         color: hexStringToColor("#E0A680"),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 userName,
//                                 style: const TextStyle(
//                                   fontSize: 20.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8.0),
//                               Text(
//                                 'Contact: $contactNumber',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 8.0),
//                               Text(
//                                 'Service: ${appointment['service'] ?? 'N/A'}',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 8.0),
//                               Text(
//                                 'Date: ${DateFormat('yyyy-MM-dd').format(appointmentDateTime)} (${DateFormat('EEEE').format(appointmentDateTime)})',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 8.0),
//                               Text(
//                                 'Time: ${TimeOfDay(hour: requestedTime['hour'], minute: requestedTime['minute']).format(context)}',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Stream<QuerySnapshot> _fetchAppointments() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return Stream.empty();
//     }

//     return FirebaseFirestore.instance
//         .collection('appointments')
//         .where('salonId', isEqualTo: user.uid)
//         .snapshots();
//   }

//   Future<DocumentSnapshot> _fetchUserDetails(String userId) async {
//     try {
//       return await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     } catch (e) {
//       print("Error fetching user details: $e");
//       rethrow;
//     }
//   }

//   Color hexStringToColor(String hexColor) {
//     hexColor = hexColor.toUpperCase().replaceAll("#", "");
//     if (hexColor.length == 6) {
//       hexColor = "FF$hexColor";
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   }
// }
