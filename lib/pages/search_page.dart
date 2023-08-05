import 'dart:math';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/pages/chatroom_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/UserModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var emailtextcontroller = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    var snapshot = await FirebaseFirestore.instance
        .collection('chatroom')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      //fetch existing
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      //create new
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatroomid: uuid.v1(),
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          lastMessage: "");

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
      print('new chatroom created');
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child:
                          searchtextfield('Search email', emailtextcontroller)),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    height: 49,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        shape: BoxShape.circle),
                    child: CupertinoButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Icon(
                        CupertinoIcons.search,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where("email", isEqualTo: emailtextcontroller.text)
                    .where("email", isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      var dataSnapshot = snapshot.data as QuerySnapshot;

                      if (dataSnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;

                        UserModel searchedUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel =
                                await getChatroomModel(searchedUser);

                            if (chatroomModel != null) {
                              setState(() {
                                Navigator.pushReplacement(context,
                                    CupertinoPageRoute(builder: (context) {
                                  return ChatRoom(
                                    targetUser: searchedUser,
                                    myUser: widget.userModel,
                                    myfirebaseUser: widget.firebaseUser,
                                    chatroom: chatroomModel,
                                  );
                                }));
                                emailtextcontroller.clear();
                              });
                            }
                          },
                          title: Text(
                            searchedUser.fullName!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(searchedUser.email!),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          leading: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            backgroundImage:
                                NetworkImage(searchedUser.profilepic!),
                          ),
                        );
                      } else {
                        return Text('No results found.');
                      }
                    } else if (snapshot.hasError) {
                      return Text('An error occured.');
                    } else {
                      return Text('No results found.');
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }))
          ],
        ),
      ),
    );
  }

  Widget searchtextfield(String txt, TextEditingController mycontroller) {
    return TextField(
      minLines: 1,
      maxLines: 1,
      cursorColor: Colors.grey,
      controller: mycontroller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
        prefixIcon: const Icon(Icons.search_outlined),
        fillColor: Colors.black.withOpacity(0.07),
        filled: true,
        hintText: txt,
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
