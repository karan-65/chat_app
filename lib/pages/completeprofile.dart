import 'dart:io';
import 'package:chat_app/modals/user_modal.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class completeprofile extends StatefulWidget {
  final usermodal Usermodal;
  final User fireabaseuser;

  const completeprofile(
      {super.key, required this.Usermodal, required this.fireabaseuser});

  @override
  State<completeprofile> createState() => _completeprofileState();
}

class _completeprofileState extends State<completeprofile> {
  File? imageFile;
  TextEditingController fname = TextEditingController();

//function for when we select the image
  void SelectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if (pickedfile != null) {
      cropimage(pickedfile);
    }
  }

//function for cropping image
  void cropimage(XFile file) async {
    File? croppedimage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedimage != null) {
      setState(() {
        imageFile = croppedimage;
      });
    }
  }

//function when we click on the image icon
  void showphotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload profile pic"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    SelectImage(ImageSource.gallery);
                  },
                  title: Text("Select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    SelectImage(ImageSource.camera);
                  },
                  title: Text("Take a photo"),
                )
              ],
            ),
          );
        });
  }

  void checkvalues() {
    String fullname = fname.text.trim();
    if (fullname == " " || imageFile == null) {
      print("please enter all the details");
    } else {
      uploadData();
    }
  }

//function for uploading image to firestore
  void uploadData() async {
    UploadTask uploadtask = FirebaseStorage.instance
        .ref("profile picture")
        .child(widget.Usermodal.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadtask;

    String? url = await snapshot.ref.getDownloadURL();
    String? fullname = fname.text.trim();

    widget.Usermodal.fullname = fullname;
    widget.Usermodal.profilepic = url;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.Usermodal.uid)
        .set(widget.Usermodal.toMap())
        .then((value) {
      print("data uploaded");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return homepage(
            Usermodal: widget.Usermodal, firebaseuser: widget.fireabaseuser);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Complete profile"),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                showphotoOptions();
              },
              child: CircleAvatar(
                backgroundImage:
                    (imageFile != null) ? FileImage(imageFile!) : null,
                radius: 60,
                child: (imageFile == null)
                    ? Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: fname,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                child: Text("Submit"),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  checkvalues();
                }),
          ],
        ),
      )),
    );
  }
}
