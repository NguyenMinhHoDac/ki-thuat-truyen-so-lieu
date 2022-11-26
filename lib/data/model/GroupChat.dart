import 'TextMessage.dart';
import 'User.dart';

class GroupChat {
  List<User> listUser;
  List<TextMessage> listMessage;

  GroupChat(this.listUser, this.listMessage);
}
