import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/model/FileMessage.dart';
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

  Uint8List getBytes(String listBytesAsString) {
    listBytesAsString =
        listBytesAsString.substring(1, listBytesAsString.length - 1);
    Uint8List bytes = Uint8List.fromList(
        listBytesAsString.split(', ').map((e) => int.parse(e)).toList());
    return bytes;
  }
  void downloadFile(FileMessage fileMessage) async {
    var bytes = getBytes(fileMessage.fileBytes);

  }

  void initData() {
    startStream();
  }

  void startStream() {
    String jsonData = '';
    socketModel.socket!.listen((data) async {
      jsonData += String.fromCharCodes(data);
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        try {
          // debugPrint('Json: $jsonData');
          if (jsonData.contains('fileBytes')) {
            listMessage.value.add(FileMessage.fromJson(jsonData));
          } else if (jsonData.contains('content')) {
            listMessage.value.add(TextMessage.fromJson(jsonData));
          }
        } catch (e) {
          debugPrint("Waiting data...");
          // debugPrint("Waiting data...: +${e.toString()}.");
        } finally {
          jsonData = '';
          update();
          scrollDown();
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
      debugPrint("File data length in Uint8List: ${bytes.length}");
      // debugPrint("File data length in string type: ${bytes.toString().length}");
      //send to socket
      var fileMessage = FileMessage(
          fileSenderName: chatRepo.currentUser.value.userName!,
          fileCreateAt: DateTime.now().toString(),
          fileName: file.path.split('/').last,
          fileBytes: bytes.toString());

      String msgSent = "file_${jsonEncode(fileMessage.toJson())}";

      socketModel.socket!.writeln(msgSent);
      debugPrint('Message send.');
      // await Socket.connect(
      //   socketModel.ipController.text,
      //   6969,
      //   timeout: const Duration(seconds: 5),
      // ).then((value) {
      //   value.writeln(msgSent);
      //   debugPrint('Message send.');
      //   return value;
      // });
    } else {
      // User canceled the picker
    }
  }
}
