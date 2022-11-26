import 'dart:convert';

class Message {
  String senderName;
  String content;
  String createAt = DateTime.now().toString();

  Message(
      {required this.senderName, required this.content, required this.createAt});

  static Message fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return Message(
        senderName: map['senderName'],
        content: map['content'],
        createAt: map['createAt']);
  }

  Map<String, dynamic> toJson() {
    return {
      "senderName": senderName,
      "content": content,
      "createAt": createAt
    };
  }
}
