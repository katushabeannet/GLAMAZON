import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glamazon/screens/ownerchat_page.dart';

class OwnerChatMainPage extends StatefulWidget {
  final String salonId;
  final String salonName;
  final String salonProfileImageUrl;

  const OwnerChatMainPage({
    Key? key,
    required this.salonId,
    required this.salonName,
    required this.salonProfileImageUrl,
  }) : super(key: key);

  @override
  _OwnerChatMainPageState createState() => _OwnerChatMainPageState();
}

class _OwnerChatMainPageState extends State<OwnerChatMainPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('salonId', isEqualTo: widget.salonId)
          .get();

      final userIds = messagesSnapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toSet()
          .toList();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      setState(() {
        _users = usersSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'userId': doc.id,
            'username': data['username'],
            'profile_picture': data['profile_picture'],
          };
        }).toList();
        _filteredUsers = _users;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['username'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 236, 220),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.salonProfileImageUrl),
              onBackgroundImageError: (_, __) => setState(() {}),
              child: widget.salonProfileImageUrl.isNotEmpty
                  ? null
                  : const Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Text(widget.salonName),
          ],
        ),
        backgroundColor: hexStringToColor("#C0724A"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profile_picture'] != null
                        ? NetworkImage(user['profile_picture'])
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                    onBackgroundImageError: (_, __) => setState(() {}),
                    child: user['profile_picture'] != null
                        ? null
                        : const Icon(Icons.person),
                  ),
                  title: Text(user['username']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerChatPage(
                          userId: user['userId'],
                          userName: user['username'],
                          userProfileImageUrl: user['profile_picture'],
                          ownerProfileImageUrl: widget.salonProfileImageUrl, // Pass owner profile image URL
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color hexStringToColor(String hexColor) {
  final color = hexColor.replaceAll("#", "");
  return Color(int.parse("FF$color", radix: 16));
}
