import 'package:chat_app/models/MessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/main.dart';

class ChatRoom extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel myUser;
  final User myfirebaseUser;
  const ChatRoom({
    Key? key,
    required this.targetUser,
    required this.chatroom,
    required this.myUser,
    required this.myfirebaseUser,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  var messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.myUser.uid,
          createdOn: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatroom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;

      FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      print('message sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.targetUser.profilepic!),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.targetUser.fullName!,
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatroom')
                      .doc(widget.chatroom.chatroomid)
                      .collection('messages')
                      .orderBy('createdOn', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        var datasnapshot = snapshot.data as QuerySnapshot;

                        return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: ((context, index) {
                              MessageModel currentmessage =
                                  MessageModel.fromMap(datasnapshot.docs[index]
                                      .data() as Map<String, dynamic>);
                              return Row(
                                mainAxisAlignment:
                                    (currentmessage.sender == widget.myUser.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: (currentmessage.sender ==
                                                widget.myUser.uid)
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              )
                                            : const BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                topRight: Radius.circular(8)),
                                        color: (currentmessage.sender ==
                                                widget.myUser.uid)
                                            ? Colors.black.withOpacity(0.8)
                                            : Colors.blueGrey[400]),
                                    child: Text(
                                      currentmessage.text!,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            }));
                      } else if (snapshot.hasError) {
                        return const Text(
                            'An error occured ! Please check your internet connection.');
                      } else {
                        return const Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: Row(
                  children: [
                    Flexible(child: messagetextfield(messageController)),
                    IconButton(
                        highlightColor: Colors.transparent,
                        onPressed: sendMessage,
                        icon: Icon(
                          Icons.send,
                          size: 30,
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget messagetextfield(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 15),
        fillColor: Colors.black.withOpacity(0.07),
        filled: true,
        hintText: 'Enter Message',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(50), right: Radius.circular(50)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.horizontal(
                left: Radius.circular(50), right: Radius.circular(50)),
            borderSide: BorderSide.none),
      ),
    );
  }
}
