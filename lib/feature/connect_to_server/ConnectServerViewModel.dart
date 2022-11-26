import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../data/model/User.dart';

class ConnectServerViewModel extends GetxController {
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  Socket? socket;

  Future<bool> connectToServer(User current) async {
    bool state = false;
    var ip = ipController.text;
    var port = int.parse(portController.text);
    socket = await Socket.connect(ip, port)
        .then((value) {
      state = true;
      return value;
    }, onError: (error) {
      debugPrint('-----Connect socket error: ${error.toString()}');
      state = false;
      return null;
    });
    if (state && (socket != null)) {
      String firstMsg = 'userIn_${jsonEncode(current.toJson())}';
      debugPrint('Message send: $firstMsg');
      socket!.writeln(firstMsg);
    }
    return state;
  }
}
