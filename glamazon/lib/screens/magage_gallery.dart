// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:async';
// import 'dart:io';

// class ManageGalleryPage extends StatefulWidget {
//   const ManageGalleryPage({Key? key}) : super(key: key);

//   @override
//   _ManageGalleryPageState createState() => _ManageGalleryPageState();
// }

// class _ManageGalleryPageState extends State<ManageGalleryPage> {
//   final List<Map<String, dynamic>> galleryItems = [];
//   String successMessage = '';
//   Color successMessageColor = Color.fromARGB(255, 199, 242, 149);
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchGalleryItems();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchGalleryItems() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final gallerySnapshot = await FirebaseFirestore.instance.collection('owners').doc(user.uid).collection('gallery').get();
//         setState(() {
//           galleryItems.clear();
//           for (var doc in gallerySnapshot.docs) {
//             galleryItems.add({
//               'id': doc.id,
//               'imagePath': doc['url'],
//               'name': doc['name'],
//               'completionTime': doc['completionTime']
//             });
//           }
//         });
//       } catch (e) {
//         print('Error fetching gallery items: $e');
//       }
//     }
//   }

//   Future<void> _deleteGalleryItem(String id, String imagePath) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         // Delete from Firestore
//         await FirebaseFirestore.instance.collection('owners').doc(user.uid).collection('gallery').doc(id).delete();

//         // Delete from Storage
//         await FirebaseStorage.instance.refFromURL(imagePath).delete();

//         setState(() {
//           galleryItems.removeWhere((item) => item['id'] == id);
//           successMessage = 'Image deleted successfully!';
//           successMessageColor = Color.fromARGB(255, 241, 134, 134);
//           _startSuccessMessageTimer();
//         });
//       } catch (e) {
//         print('Error deleting gallery item: $e');
//       }
//     }
//   }

//   Future<void> _editGalleryItem(String id, String currentName, String currentCompletionTime, String currentImagePath) async {
//     final ImagePicker picker = ImagePicker();
//     final TextEditingController nameController = TextEditingController(text: currentName);
//     final TextEditingController completionTimeController = TextEditingController(text: currentCompletionTime);
//     bool _isLoading = false;
//     String? newImageUrl;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Edit Image Details'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: nameController,
//                     decoration: const InputDecoration(labelText: 'Image Name'),
//                   ),
//                   TextField(
//                     controller: completionTimeController,
//                     decoration: const InputDecoration(labelText: 'Completion Time (hours)'),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final XFile? media = await picker.pickImage(source: ImageSource.gallery);
//                       if (media != null) {
//                         setState(() {
//                           _isLoading = true;
//                         });

//                         String fileName = media.name;
//                         String filePath = 'gallery/${FirebaseAuth.instance.currentUser!.uid}/$fileName';
//                         File file = File(media.path);

//                         try {
//                           await FirebaseStorage.instance.ref(filePath).putFile(file);
//                           newImageUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

//                           // Delete old image from storage
//                           await FirebaseStorage.instance.refFromURL(currentImagePath).delete();
//                         } catch (e) {
//                           print('Error updating gallery item: $e');
//                         } finally {
//                           setState(() {
//                             _isLoading = false;
//                           });
//                         }
//                       }
//                     },
//                     child: const Text('Upload New Image'),
//                   ),
//                   if (_isLoading)
//                     const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 TextButton(
//                   child: const Text('Save'),
//                   onPressed: () async {
//                     if (nameController.text.isNotEmpty &&
//                         completionTimeController.text.isNotEmpty) {
//                       setState(() {
//                         _isLoading = true;
//                       });

//                       try {
//                         await FirebaseFirestore.instance.collection('owners').doc(FirebaseAuth.instance.currentUser!.uid).collection('gallery').doc(id).update({
//                           'url': newImageUrl ?? currentImagePath,
//                           'name': nameController.text,
//                           'completionTime': 'Completion time: ${completionTimeController.text} hours',
//                         });

//                         setState(() {
//                           final index = galleryItems.indexWhere((item) => item['id'] == id);
//                           if (index != -1) {
//                             galleryItems[index] = {
//                               'id': id,
//                               'imagePath': newImageUrl ?? currentImagePath,
//                               'name': nameController.text,
//                               'completionTime': 'Completion time: ${completionTimeController.text} hours',
//                             };
//                           }
//                           successMessage = 'Image edited successfully!';
//                           successMessageColor = Colors.lightGreen;
//                           _startSuccessMessageTimer();
//                         });
//                       } catch (e) {
//                         print('Error updating gallery item: $e');
//                       } finally {
//                         setState(() {
//                           _isLoading = false;
//                         });
//                         Navigator.of(context).pop();
//                       }
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _startSuccessMessageTimer() {
//     _timer?.cancel();
//     _timer = Timer(const Duration(seconds: 3), () {
//       setState(() {
//         successMessage = '';
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Gallery'),
//         backgroundColor: const Color(0xFF882D17),
//       ),
//       body: Column(
//         children: [
//           if (successMessage.isNotEmpty)
//             Container(
//               color: successMessageColor,
//               padding: const EdgeInsets.all(8.0),
//               margin: const EdgeInsets.only(bottom: 10.0),
//               child: Text(
//                 successMessage,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: galleryItems.length,
//               itemBuilder: (context, index) {
//                 final item = galleryItems[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   child: Row(
//                     children: [
//                       Image.network(
//                         item['imagePath']!,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['name']!,
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(item['completionTime']!),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () {
//                           _editGalleryItem(item['id']!, item['name']!, item['completionTime']!, item['imagePath']!);
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text('Delete Image'),
//                                 content: const Text('Are you sure you want to delete this image?'),
//                                 actions: [
//                                   TextButton(
//                                     child: const Text('Cancel'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                   TextButton(
//                                     child: const Text('Delete'),
//                                     onPressed: () {
//                                       _deleteGalleryItem(item['id']!, item['imagePath']!);
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
