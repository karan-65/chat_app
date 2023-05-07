class chatroom {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;

  chatroom({
    this.chatroomid,
    this.participants,
    this.lastmessage,
  });

  chatroom.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage = map["lastmessage"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastmessage,
    };
  }
}
