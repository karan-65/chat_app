import 'package:chat_app/modals/chatroom_modal.dart';
import 'package:chat_app/modals/firebasehelper.dart';
import 'package:chat_app/modals/user_modal.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

class homepage extends StatefulWidget {
  final usermodal Usermodal;
  final User firebaseuser;

  const homepage(
      {super.key, required this.Usermodal, required this.firebaseuser});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return loginpage();
                }));
              },
              icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("participants.${widget.Usermodal.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatroomsnapshot =
                        snapshot.data as QuerySnapshot;

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        chatroom chatroommodal = chatroom.fromMap(
                            chatroomsnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatroommodal.participants!;

                        List<String> participantskeys =
                            participants.keys.toList();
                        participants.remove(widget.Usermodal.uid);

                        return FutureBuilder(
                          future: firebasehelper
                              .getusrmodelbyid(participantskeys[0]),
                          builder: (context, userdata) {
                            if (userdata.connectionState ==
                                ConnectionState.done) {
                              if (userdata.data != null) {
                                usermodal targetuser =
                                    userdata.data as usermodal;

                                return ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetuser.profilepic.toString())),
                                  title: Text(targetuser.fullname.toString()),
                                  subtitle: Text(
                                      chatroommodal.lastmessage.toString()),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                      itemCount: chatroomsnapshot.docs.length,
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return Center(
                      child: Text("no chats"),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Searchpage(
                Usermodal: widget.Usermodal, firebaseuser: widget.firebaseuser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
