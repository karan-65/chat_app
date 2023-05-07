import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/modals/chatroom_modal.dart';
import 'package:chat_app/modals/message_modal.dart';
import 'package:chat_app/modals/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../modals/chatroom_modal.dart';

class chatroompage extends StatefulWidget {
  final usermodal Usermodal;
  final User Firebaseuser;
  final usermodal targetuser;
  final chatroom Chatroom;

  const chatroompage(
      {super.key,
      required this.Usermodal,
      required this.Firebaseuser,
      required this.targetuser,
      required this.Chatroom});

  @override
  State<chatroompage> createState() => _chatroomState();
}

class _chatroomState extends State<chatroompage> {
  TextEditingController messagecontroller = TextEditingController();

  void sendmessage() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();
    if (msg != " ") {
      messagmodal newmessage = messagmodal(
          messageid: uuid.v1(),
          sender: widget.Usermodal.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.Chatroom.chatroomid)
          .collection("messages")
          .doc(newmessage.messageid)
          .set(newmessage.toMap());
      widget.Chatroom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.Chatroom.chatroomid)
          .set(widget.Chatroom.toMap());

      log("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(widget.targetuser.profilepic.toString()),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetuser.fullname.toString())
        ]),
      ),
      body: SafeArea(
          child: Container(
        child: Column(children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.Chatroom.chatroomid)
                  .collection("messages")
                  .orderBy("createdon", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasapshot = snapshot.data as QuerySnapshot;

                    return ListView.builder(
                      reverse: true,
                      itemBuilder: (context, index) {
                        messagmodal currentmessage = messagmodal.fromMap(
                            datasapshot.docs[index].data()
                                as Map<String, dynamic>);

                        return Row(
                          mainAxisAlignment:
                              (currentmessage.sender == widget.Usermodal.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                margin: EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: (currentmessage.sender ==
                                          widget.Usermodal.uid)
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  currentmessage.text.toString(),
                                  style: TextStyle(color: Colors.white),
                                )),
                          ],
                        );
                      },
                      itemCount: datasapshot.docs.length,
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "An error occured please check your internet connection"),
                    );
                  } else {
                    return Center(
                      child: Text("say hi to your new friend"),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
          Container(
            color: Colors.grey[300],
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  controller: messagecontroller,
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: "Enter message", border: InputBorder.none),
                )),
                IconButton(
                    onPressed: () {
                      sendmessage();
                    },
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.secondary))
              ],
            ),
          )
        ]),
      )),
    );
  }
}
