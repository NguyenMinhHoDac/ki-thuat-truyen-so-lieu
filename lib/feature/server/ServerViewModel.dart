import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:tcp_chat/data/model/FileMessage.dart';
import 'package:tcp_chat/data/model/TextMessage.dart';

class ServerViewModel extends GetxController {
  ServerSocket? serverSocket;
  String port = '6969';

  TextEditingController portController = TextEditingController();
  RxList log = [].obs;

  List<Socket> clients = [];
  List<TextMessage> txtMsgs = [];
  List<FileMessage> fileMsgs = [];

  ServerViewModel(String _port) {
    port = _port;
  }

  static Future<String> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface =
          interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface =
            interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) =>
              !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (ex) {
          return 'undefined';
        }
      }
    }
  }

  Future<void> startServer() async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4,
        int.parse(portController.text != '' ? portController.text : port));
    if (serverSocket != null) {
      log.value.add(
          'Server started at ${await getLocalIpAddress()}:${serverSocket!.port} (local)');
      update();
      serverSocket!.listen((Socket client) {
        clients.add(client);
        log.value.add(
            'Connection from ${client.remoteAddress.address}:${client.remotePort}');
        List<int> temp = [];
        client.listen((List<int> data) async {
          if (data.isNotEmpty) {
            temp.addAll(data);
            try {
              var msg = String.fromCharCodes(temp);
              // debugPrint(msg);
              // log.value.add("Message: $msg");
              update();

              if (msg.contains('userIn_')) {
                temp.clear();
                log.value.add('User join.');
                update();
              } else if (msg.contains('userOut_')) {
                temp.clear();
                clients.remove(client);
                log.value.add('User out.');
                update();
              } else if (msg.contains('msg_') && msg.contains('content')) {
                temp.clear();
                log.value.add('Text message handled.');
                update();
                var json = msg.split("_")[1];
                var txtMsg = TextMessage.fromJson(json);
                txtMsgs.add(txtMsg);
                for (var client in clients) {
                  client.writeln(jsonEncode(txtMsg.toJson()));
                }
              } else if (msg.contains('file_') &&
                  msg.contains('fileBytes') &&
                  msg.contains('{') &&
                  msg.contains('}')) {
                temp.clear();
                log.value.add('File message handled.');
                update();
                var json = msg.split("_")[1];
                var fileMsg = FileMessage.fromJson(json);
                fileMsgs.add(fileMsg);
                for (var client in clients) {
                  client.writeln(jsonEncode(fileMsg.toJson()));
                }
              } else {
                debugPrint("Multi package case, ignore.");
              }
            } catch (error) {
              log.value.add("Error : $error");
              update();
            }
          }
        });
      });
    }
  }

  Future<void> closeServer() async {
    await serverSocket!.close();
    debugPrint('Server closed');
  }

  void executeMessage(Socket client, List<int> data) {
    try {
      var msg = String.fromCharCodes(data);
      // debugPrint(msg);
      // log.value.add("Message: $msg");
      update();

      if (msg.contains('userIn_')) {
        log.value.add('User join.');
        update();
      } else if (msg.contains('userOut_')) {
        clients.remove(client);
        log.value.add('User out.');
        update();
      } else if (msg.contains('msg_') && msg.contains('content')) {
        log.value.add('Text message handled.');
        update();
        var json = msg.split("_")[1];
        var txtMsg = TextMessage.fromJson(json);
        txtMsgs.add(txtMsg);
        for (var client in clients) {
          client.writeln(jsonEncode(txtMsg.toJson()));
        }
      } else if (msg.contains('file_') &&
          msg.contains('fileBytes') &&
          msg.contains('{') &&
          msg.contains('}')) {
        log.value.add('File message handled.');
        update();
        var json = msg.split("_")[1];
        var fileMsg = FileMessage.fromJson(jsonDecode(json));
        fileMsgs.add(fileMsg);
        for (var client in clients) {
          client.writeln(jsonEncode(fileMsg.toJson()));
        }
      } else {
        debugPrint("Multi package case, ignore.");
      }
    } catch (error) {
      log.value.add("Error : $error");
      update();
    }
    update();
  }
}
