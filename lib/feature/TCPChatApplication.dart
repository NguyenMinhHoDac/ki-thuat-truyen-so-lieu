import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/repository/ChatRepository.dart';
import 'package:tcp_chat/feature/connect_to_server/ConnectServerView.dart';

class TCPChatApplication extends StatefulWidget {
  const TCPChatApplication({Key? key}) : super(key: key);

  @override
  State<TCPChatApplication> createState() => _TCPChatApplicationState();
}

class _TCPChatApplicationState extends State<TCPChatApplication> {
  @override
  Widget build(BuildContext context) {
    Get.put(ChatRepository(), permanent: true);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCP Chat App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const ConnectServerView(),
    );
  }
}
