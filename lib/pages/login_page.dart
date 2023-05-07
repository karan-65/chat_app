import 'package:chat_app/modals/user_modal.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class loginpage extends StatefulWidget {
  const loginpage({Key? key}) : super(key: key);

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  void checkvalues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();

    if (email == " " || password == " ") {
      print("please fill all the fields");
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credientals;
    try {
      credientals = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (credientals != null) {
      String uid = credientals.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      usermodal userModal =
          usermodal.fromMap(userData.data() as Map<String, dynamic>);

      print("login succesfull");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return homepage(Usermodal: userModal, firebaseuser: credientals!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton(
                    child: Text("Login"),
                    onPressed: () {
                      checkvalues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Dont have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: Text("Signup"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Signup();
                }));
              }),
        ],
      )),
    );
  }
}
