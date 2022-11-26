import 'dart:io';

import 'package:get/state_manager.dart';
import 'package:tcp_chat/data/model/User.dart';

class ChatRepository extends GetxController {
  Rx<User> currentUser =
      User(uid: 'null', userName: 'nulk', createAt: DateTime.now()).obs;
}
