class messagmodal {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  messagmodal(
      {this.messageid, this.createdon, this.seen, this.sender, this.text});
//map to object
  messagmodal.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    messageid = map["messageid"];
    createdon = map["createdon"].toDate();
  }
//object to map
  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "messageid": messageid,
      "createdon": createdon,
    };
  }
}
