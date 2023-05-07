import 'package:chat_app/modals/firebasehelper.dart';
import 'package:chat_app/modals/user_modal.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //checking if user is logged in
  User? currentuser = FirebaseAuth.instance.currentUser;

  if (currentuser != null) {
    usermodal? thisusermodal =
        await firebasehelper.getusrmodelbyid(currentuser.uid);
    if (thisusermodal != null) {
      runApp(MyApploggedIN(
        Usermodal: thisusermodal,
        firebaseuser: currentuser,
      ));
    } else {
      runApp(MyApp());
    }
  } else {
    runApp(MyApp());
  }
}

//not logged in
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginpage(),
    );
  }
}

//logged in
class MyApploggedIN extends StatelessWidget {
  final usermodal Usermodal;
  final User firebaseuser;

  const MyApploggedIN(
      {super.key, required this.Usermodal, required this.firebaseuser});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepage(
        Usermodal: Usermodal,
        firebaseuser: firebaseuser,
      ),
    );
  }
}
