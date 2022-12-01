import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/feature/client/connect_to_server/ConnectServerView.dart';
import 'package:tcp_chat/feature/server/ServerView.dart';

class SelectModeView extends StatefulWidget {
  const SelectModeView({Key? key}) : super(key: key);

  @override
  State<SelectModeView> createState() => _SelectModeViewState();
}

class _SelectModeViewState extends State<SelectModeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TCP CHAT APP"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                //go to client view
                Get.to(() => const ConnectServerView());
              },
              child: const Text("Client"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                //go to server view
                Get.to(() => const ServerView());
              },
              child: const Text("Server"),
            ),
          ],
        ),
      ),
    );
  }
}
