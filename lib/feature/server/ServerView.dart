import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ServerViewModel.dart';

class ServerView extends StatefulWidget {
  const ServerView({Key? key}) : super(key: key);

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  final viewModel = Get.put(ServerViewModel("6969"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SERVER"),
        actions: [
          IconButton(
            onPressed: () {
              // clear log
              viewModel.log.value.clear();
              viewModel.update();
            },
            icon: const Icon(Icons.cleaning_services_sharp),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //get dialog comfirm
            Get.defaultDialog(
              title: "Are you sure?",
              middleText: "Do you want to exit?",
              textConfirm: "Yes",
              textCancel: "No",
              confirmTextColor: Colors.white,
              cancelTextColor: Colors.black,
              buttonColor: Colors.orange,
              onConfirm: () {
                Get.back();
                Get.back();
                viewModel.closeServer();
              },
              onCancel: () {},
            );
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                        constraints: BoxConstraints(maxHeight: 50),
                        border: OutlineInputBorder(),
                        hintText: 'Port'),
                    controller: viewModel.portController,
                    onSubmitted: (value) {
                      viewModel.portController.text = value;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.startServer();
                  },
                  child: const Text("Start Server"),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.closeServer();
                  },
                  child: const Text("Close Server"),
                ),
              ),
              //log
            ],
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),
          Expanded(
            child: GetBuilder<ServerViewModel>(builder: (model) {
              return ListView.builder(
                itemCount: viewModel.log.value.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(viewModel.log.value[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
