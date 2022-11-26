import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/repository/ChatRepository.dart';
import 'package:tcp_chat/feature/connect_to_server/ConnectServerViewModel.dart';

import '../../data/model/Message.dart';
import '../../data/model/User.dart';

class ChatScreenViewModel extends GetxController {
  var socketModel = Get.find<ConnectServerViewModel>();

  TextEditingController msgController = TextEditingController();
  ScrollController chatScrollController = ScrollController();

  RxList chattingUser = [].obs;
  RxList<Message> listMessage = <Message>[].obs;

  ChatRepository chatRepo = Get.find<ChatRepository>();

  void setCurrentUser(User currentUser) {
    chatRepo.currentUser.value = currentUser;
  }

  void userLeaveChat(User userLeave) {
    // String leaveMsg = 'userOut_${jsonEncode(userLeave.toJson())}\n';
    String leaveMsg = 'userOut_end';

    debugPrint('Message send: $leaveMsg');
    socketModel.socket!.writeln(leaveMsg);
  }

  void sendMessage(String message) {
    if (message != '' && message != null) {
      var msg = Message(
        senderName: chatRepo.currentUser.value.userName!,
        createAt: DateTime.now().toString(),
        content: message,
      );
      String msgSent = "msg_${jsonEncode(msg.toJson())}";
      debugPrint('Message send: $msgSent');
      socketModel.socket!.writeln(msgSent);
      msgController.text = '';
    }
  }

  void scrollDown() {
    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn);
  }

  void initData() {
    startStream();
  }

  void startStream() {
    String jsonMessage = '';
    socketModel.socket!.listen((data) {
      jsonMessage += String.fromCharCodes(data);
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        try {
          // debugPrint('Json: $jsonMessage');
          listMessage.value.add(Message.fromJson(jsonMessage));
          // debugPrint('Have a new message');
          jsonMessage = '';
          update();
          scrollDown();
        } catch (e) {
          debugPrint(
              "Parse json error because not full package data(just ignore): +${e.toString()}.");
        }
      });
    }, onError: (error) {}, onDone: () {});
  }

  void endStream() {}

  Future<void> selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(initialDirectory: '');
    if (result != null) {
      // debugPrint("Selected file: ${result.files.single.path!}");

      String fileName = result.files.first.name;
      debugPrint("Selected file: ${result.files.first.name}");
      Uint8List? fileBytes = result.files.first.bytes;

      // await socketModel.socket!.addStream(file.openRead());
      // debugPrint("Data write");
    } else {
      // User canceled the picker
    }
  }
}
