import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/model/User.dart';
import '../chat_screen/ChatScreenView.dart';
import 'ConnectServerViewModel.dart';

class ConnectServerView extends StatefulWidget {
  const ConnectServerView({Key? key}) : super(key: key);

  @override
  State<ConnectServerView> createState() => _ConnectServerViewState();
}

class _ConnectServerViewState extends State<ConnectServerView> {
  final viewModel = Get.put(ConnectServerViewModel(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CLIENT'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect to server',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              //192.168.2.8
              TextField(
                maxLines: 1,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Server IP Address'),
                controller: viewModel.ipController,
                onSubmitted: (value) {
                  viewModel.ipController.text = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 1,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Server port'),
                controller: viewModel.portController,
                onSubmitted: (value) {
                  viewModel.portController.text = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'User infomations',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 1,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Username'),
                controller: viewModel.userNameController,
                onSubmitted: (value) {
                  viewModel.userNameController.text = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        var temp = User(
                            uid: Random().nextInt(10000).toString(),
                            userName: viewModel.userNameController.text,
                            createAt: DateTime.now());
                        //Connect thanh cong -> tao user -> direct to chat
                        await viewModel.connectToServer(temp).then((value) {
                          Get.snackbar('Server',
                              value ? 'Connect success' : 'Connect failed.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.black,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1));
                          if (value) {
                            // Get.dialog(Container(
                            //     color: Colors.white,
                            //     margin: const EdgeInsets.symmetric(
                            //         horizontal: 20, vertical: 200),
                            //     padding: const EdgeInsets.all(20),
                            //     child: Center(
                            //         child: Text(
                            //       jsonEncode(temp.toJson()),
                            //       style: const TextStyle(
                            //           fontSize: 20, color: Colors.black),
                            //     ))));
                            Get.to(() => ChatScreenView(temp));
                          } else {}
                        });
                      },
                      child: const Text('Connect'))),
            ],
          ),
        ),
      ),
    );
  }
}
