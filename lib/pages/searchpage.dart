import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/modals/chatroom_modal.dart';
import 'package:chat_app/modals/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chatroompage.dart';

class Searchpage extends StatefulWidget {
  final usermodal Usermodal;
  final User firebaseuser;

  Searchpage({required this.Usermodal, required this.firebaseuser});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  TextEditingController searchcontroller = TextEditingController();

  Future<chatroom?> getChatroommodel(usermodal targetuser) async {
    chatroom? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.Usermodal.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch the existing one
      var Docdata = snapshot.docs[0].data();
      chatroom exisitingchatroom =
          chatroom.fromMap(Docdata as Map<String, dynamic>);
      // print("chatroom already created");
      chatRoom = exisitingchatroom;
    } else {
      // create a new one
      chatroom newchatroom =
          chatroom(chatroomid: uuid.v1(), lastmessage: "", participants: {
        widget.Usermodal.uid.toString(): true,
        targetuser.uid.toString(): true,
      });

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());
      log("new chat room createed");
      chatRoom = newchatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: searchcontroller,
              decoration: InputDecoration(labelText: "Email Address"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                child: Text(
                  "Search",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () {
                  setState(() {});
                }),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: searchcontroller.text)
                    .where("email", isNotEqualTo: widget.Usermodal.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      if (dataSnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;

                        usermodal searcheduser = usermodal.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            chatroom? chatRoom =
                                await getChatroommodel(searcheduser);
                            if (chatRoom != null) {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return chatroompage(
                                  targetuser: searcheduser,
                                  Usermodal: widget.Usermodal,
                                  Firebaseuser: widget.firebaseuser,
                                  Chatroom: chatRoom,
                                );
                              }));
                            }
                          },
                          leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searcheduser.profilepic!)),
                          title: Text(searcheduser.fullname!),
                          subtitle: Text(searcheduser.email!),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return Text("No results found");
                      }
                    } else if (snapshot.hasError) {
                      return Text("error found");
                    } else {
                      return Text("No results found");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ],
        ),
      )),
    );
  }
}
