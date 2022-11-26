import 'dart:convert';

class User {
  String? uid;
  String? userName;
  DateTime createAt = DateTime.now();
  String photoUrl = 'https://i.pravatar.cc/200';

  User({required this.uid, required this.userName, required this.createAt});

  static User fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return User(
        uid: map['uid'], userName: map['userName'], createAt: map['createAt']);
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "userName": userName,
      "createAt": createAt.toIso8601String(),
      "photoUrl": photoUrl,
    };
  }
}
