import 'package:chat_app/modals/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class firebasehelper {
  static Future<usermodal?> getusrmodelbyid(String id) async {
    usermodal? Usermodal;

    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(id).get();

    if (docsnap != null) {
      Usermodal = usermodal.fromMap(docsnap.data() as Map<String, dynamic>);
    }
    return Usermodal;
  }
}
