import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcp_chat/data/model/TextMessage.dart';
import 'package:tcp_chat/data/model/User.dart';
import 'package:tcp_chat/feature/client/chat_screen/ChatScreenViewModel.dart';
import 'package:tcp_chat/feature/client/connect_to_server/ConnectServerView.dart';



class ChatScreenView extends StatefulWidget {
  final User currentUser;

  const ChatScreenView(this.currentUser, {Key? key}) : super(key: key);

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final viewModel = Get.put(ChatScreenViewModel());

  @override
  void initState() {
    viewModel.setCurrentUser(widget.currentUser);
    viewModel.initData();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.endStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
        leading: IconButton(
          onPressed: () {
            //dialog confirm quit
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Do you want to quit?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.endStream();
                          Get.offAll(() => const ConnectServerView());
                          (widget.currentUser.userName != null &&
                                  widget.currentUser.userName != '')
                              ? viewModel.userLeaveChat(widget.currentUser)
                              : {};
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                });
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
              onPressed: () {
                debugPrint(viewModel.listMessage.value.length.toString());
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          color: Colors.white,
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                controller: viewModel.chatScrollController,
                child: GetBuilder<ChatScreenViewModel>(
                  builder: (controller) => Column(
                    children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                        ] +
                        viewModel.listMessage.value
                            .map((element) => _messageCard(element))
                            .toList(),
                  ),
                ),
              ),
            ),
            _sendBox(),
          ]),
        ),
      ),
    );
  }

  Widget _sendBox() {
    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 5, left: 10, right: 10),
      color: Colors.white,
      // width: Get.width,
      child: Row(
        children: [
          TextField(
            maxLines: 1,
            decoration: InputDecoration(
                constraints: BoxConstraints(maxWidth: Get.width - 20),
                prefixIcon: IconButton(
                    onPressed: () {
                      viewModel.selectFile();
                    },
                    icon: const Icon(Icons.add)),
                suffixIcon: IconButton(
                    onPressed: () {
                      viewModel.sendMessage(viewModel.msgController.text);
                    },
                    icon: const Icon(Icons.send)),
                border: const OutlineInputBorder(),
                hintText: 'Message'),
            controller: viewModel.msgController,
            onSubmitted: (value) {
              viewModel.msgController.text = value;
              viewModel.sendMessage(value);
              Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _messageCard(dynamic msg) {
    return (msg is TextMessage)
        ? Column(
            crossAxisAlignment: msg.senderName != widget.currentUser.userName
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Text(msg.senderName),
              ),
              Row(
                mainAxisAlignment: msg.senderName != widget.currentUser.userName
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: msg.senderName != widget.currentUser.userName,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: msg.senderName != widget.currentUser.userName
                              ? Colors.grey
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        msg.content,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: msg.senderName == widget.currentUser.userName,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment:
                msg.fileSenderName != widget.currentUser.userName
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Text(msg.fileSenderName),
              ),
              Row(
                mainAxisAlignment:
                    msg.fileSenderName != widget.currentUser.userName
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: msg.fileSenderName != widget.currentUser.userName,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint(msg.fileBytes.length.toString());
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: Text(
                                  'Do you want to download ${msg.fileName}?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    viewModel.downloadFile(msg);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: Get.width * 0.5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: msg.fileSenderName !=
                                    widget.currentUser.userName
                                ? Colors.grey
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Image.memory(
                              viewModel.getBytes(msg.fileBytes),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              msg.fileName,
                              maxLines: 13,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: msg.fileSenderName == widget.currentUser.userName,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
