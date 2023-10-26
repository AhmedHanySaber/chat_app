// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//   static const String screenRoute = 'chat_screen';
//
//   @override
//   ChatScreenState createState() => ChatScreenState();
// }
//
// class ChatScreenState extends State<ChatScreen> {
//   final _fireStore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   late User loggedInUser;
//   late String messageText;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }
//
//   void getCurrentUser() {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         loggedInUser = user;
//         if (kDebugMode) {
//           print(loggedInUser.email);
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.yellow[900],
//         title: Row(
//           children: [
//             Image.asset('assets/logo.png', height: 25),
//             const SizedBox(width: 10),
//             const Text('MessageMe')
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _auth.signOut();
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close),
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             StreamBuilder<QuerySnapshot>(
//               stream: _fireStore
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       backgroundColor: Colors.yellow[900],
//                     ),
//                   );
//                 }
//                 final messages = snapshot.data!.docs;
//                 List<MessageWidget> messageWidgets = [];
//                 for (var message in messages) {
//                   final messageText = message.get('text') as String;
//                   final messageSender = message.get('sender') as String;
//                   final messageWidget = MessageWidget(
//                     messageText: messageText,
//                     messageSender: messageSender,
//                   );
//                   messageWidgets.add(messageWidget);
//                 }
//                 return Expanded(
//                   child: ListView(
//                     reverse: true, // Show new messages at the bottom
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                     children: messageWidgets,
//                   ),
//                 );
//               },
//             ),
//             Container(
//               decoration: const BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.orange,
//                     width: 2,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       onChanged: (value) {
//                         messageText = value;
//                       },
//                       decoration: const InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                           vertical: 10,
//                           horizontal: 20,
//                         ),
//                         hintText: 'Write your message here...',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       _fireStore.collection('messages').add({
//                         'text': messageText,
//                         'sender': loggedInUser.email,
//                       });
//                     },
//                     child: Text(
//                       'Send',
//                       style: TextStyle(
//                         color: Colors.blue[800],
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MessageWidget extends StatelessWidget {
//   const MessageWidget({
//     Key? key,
//     required this.messageText,
//     required this.messageSender,
//   }) : super(key: key);
//
//   final String messageText;
//   final String messageSender;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           Material(
//             color: Colors.blue[800],
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               child: Text(
//                 '$messageText from $messageSender',
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const String screenRoute = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _loggedInUser;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _loggedInUser = _auth.currentUser!;
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': messageText,
        'sender': _loggedInUser.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;
                final reversedMessages = messages.reversed.toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final message = reversedMessages[index];
                    final messageText = message['text'] as String;
                    final messageSender = message['sender'] as String;
                    final isMe = messageSender == _loggedInUser.email;

                    return MessageBubble(
                      text: messageText,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomLeft: isMe ? Radius.circular(30.0) : Radius.zero,
              bottomRight: isMe ? Radius.zero : Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.grey[300],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}