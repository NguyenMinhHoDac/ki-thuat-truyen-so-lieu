import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/repository/ChatRepository.dart';
import 'package:tcp_chat/feature/connect_to_server/ConnectServerViewModel.dart';

import '../../data/model/TextMessage.dart';
import '../../data/model/User.dart';

class ChatScreenViewModel extends GetxController {
  var socketModel = Get.find<ConnectServerViewModel>();

  TextEditingController msgController = TextEditingController();
  ScrollController chatScrollController = ScrollController();

  RxList chattingUser = [].obs;
  RxList listMessage = [].obs;

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
      var msg = TextMessage(
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
    String jsonData = '';
    socketModel.socket!.listen((data) {
      jsonData += String.fromCharCodes(data);
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        try {
          // debugPrint('Json: $jsonData');
          listMessage.value.add(TextMessage.fromJson(jsonData));
          // listMessage.value
          //     .add(FileMessage.fromJson(jsonData.split('_')[2]));

          jsonData = '';
          update();
          scrollDown();
        } catch (e) {
          // debugPrint("Waiting data...");
          debugPrint("Waiting data...: +${e.toString()}.");
        }
      });
    }, onError: (error) {}, onDone: () {});
  }

  void endStream() {}

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {

      //read file bytes
      File file = File(result.files.single.path!);
      Uint8List bytes = file.readAsBytesSync();
      debugPrint("File name: ${file.path.split('/').last}");
      debugPrint("File data length: ${bytes.length}");
      //send to socket
      String msgSent = "file_${file.path.split('/').last}_${bytes.toString()}";
      debugPrint('Message send!');
      socketModel.socket!.writeln(msgSent);

      // await socketModel.socket!.addStream(file.openRead()).then((value) {
      //   debugPrint("Send file success");
      // }, onError: (error) {
      //   debugPrint("Send file error: ${error.toString()}");
      // });
    } else {
      // User canceled the picker
    }
  }
}
