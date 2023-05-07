class usermodal {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  usermodal({this.email, this.fullname, this.uid, this.profilepic});

  usermodal.fromMap(Map<String, dynamic> map) {
    uid = map["id"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
    };
  }
}
