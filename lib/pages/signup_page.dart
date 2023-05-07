import 'package:chat_app/modals/user_modal.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  TextEditingController cpasswordcontroler = TextEditingController();

  void checkvalues() {
    String email = emailcontroler.text.trim();
    String password = passwordcontroler.text.trim();
    String cpassword = cpasswordcontroler.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      print("please fill all the details");
    } else if (password != cpassword) {
      print("paswords doesnt match");
    } else {
      Signup(email, password);
    }
  }

  void Signup(String email, String password) async {
    UserCredential? credientals;
    try {
      credientals = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }
    if (credientals != null) {
      String uid = credientals.user!.uid;
      usermodal newuser = usermodal(
        uid: uid,
        email: email,
        profilepic: "",
        fullname: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        print("new user created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return completeprofile(
            Usermodal: newuser,
            fireabaseuser: credientals!.user!,
          );
        }));
      });
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
                    controller: emailcontroler,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: passwordcontroler,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: cpasswordcontroler,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton(
                    child: Text("Signup"),
                    onPressed: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) {
                      //   return completeprofile();
                      // }));
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
            "Already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: Text("Login"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      )),
    );
  }
}
