import 'dart:convert';

class TextMessage {
  String senderName;
  String content;
  String createAt = DateTime.now().toString();

  TextMessage(
      {required this.senderName, required this.content, required this.createAt});

  static TextMessage fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return TextMessage(
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
