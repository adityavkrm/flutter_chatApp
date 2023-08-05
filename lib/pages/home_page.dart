import 'package:chat_app/login_or_register.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/pages/chatroom_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/UserModel.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  HomePage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black.withOpacity(0.8),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) {
                  return LoginOrSignup();
                }));
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
        title: const Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(
          CupertinoIcons.chat_bubble_fill,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatroom')
                .where('participants.${widget.userModel.uid}', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  var chatroomsnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                      itemCount: chatroomsnapshot.docs.length,
                      itemBuilder: ((context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            chatroomsnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;

                        List<String> participantkeys =
                            participants.keys.toList();

                        participantkeys.remove(widget.userModel.uid);

                        return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantkeys[0]),
                            builder: (context, userdata) {
                              if (userdata.connectionState ==
                                  ConnectionState.done) {
                                if (userdata.hasData) {
                                  UserModel targetuser =
                                      userdata.data as UserModel;

                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ListTile(
                                      tileColor: Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      onTap: () {
                                        Navigator.push(context,
                                            CupertinoPageRoute(
                                                builder: (context) {
                                          return ChatRoom(
                                              targetUser: targetuser,
                                              chatroom: chatRoomModel,
                                              myUser: widget.userModel,
                                              myfirebaseUser:
                                                  widget.firebaseUser);
                                        }));
                                      },
                                      title: Text(
                                        targetuser.fullName!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: (chatRoomModel.lastMessage
                                                  .toString() !=
                                              "")
                                          ? Text(chatRoomModel.lastMessage!)
                                          : Text('No Messages yet!'),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            targetuser.profilepic!),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      }));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return const Center(
                    child: Text('No chats yet..'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      )),
    );
  }
}
