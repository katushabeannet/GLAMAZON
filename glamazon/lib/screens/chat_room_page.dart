import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final List<Message> messages = [
    Message(
      text: 'Hello! How can I help you today?',
      isOwner: true,
      profileImage:
          'assets/images/spa.jpeg', // Replace with salon owner image asset
    ),
    Message(
      text: 'Hi! I want to know more about your services.',
      isOwner: false,
      profileImage: 'assets/images/spa.jpg', // Replace with user image asset
    ),
    Message(
      text:
          'Sure! We offer a variety of services including haircuts, styling, and coloring.',
      isOwner: true,
      profileImage:
          'assets/images/spa.jpeg', // Replace with salon owner image asset
    ),
    Message(
      text: 'Great! I would like to book an appointment for a haircut.',
      isOwner: false,
      profileImage: 'assets/images/spa.jpg', // Replace with user image asset
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        backgroundColor: Color(0xFF6A1B1A), // Darker Sienna shade
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Add send message functionality
                  },
                  color: Color(0xFF6A1B1A), // Darker Sienna shade
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isOwner;
  final String profileImage;

  Message({
    required this.text,
    required this.isOwner,
    required this.profileImage,
  });
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isOwner ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isOwner)
              CircleAvatar(
                backgroundImage: AssetImage(message.profileImage),
              ),
            if (message.isOwner) SizedBox(width: 10),
            Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: message.isOwner
                    ? Colors.grey[300]
                    : Color(0xFFAA4A30), // Grey for owner, Sienna for user
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isOwner ? Colors.black : Colors.white,
                ),
              ),
            ),
            if (!message.isOwner) SizedBox(width: 10),
            if (!message.isOwner)
              CircleAvatar(
                backgroundImage: AssetImage(message.profileImage),
              ),
          ],
        ),
      ),
    );
  }
}
