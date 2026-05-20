import 'package:chat_app/core/models/chat_enums.dart';

class ChatPaths {
  static String collectionFor(ChatScope scope) {
    switch (scope) {
      case ChatScope.direct:
        return 'ychatRooms';
      case ChatScope.group:
        return 'ygroups';
      case ChatScope.channel:
        return 'ychannels';
    }
  }

  static String membershipSubcollection(ChatScope scope) {
    switch (scope) {
      case ChatScope.direct:
        return 'participants';
      case ChatScope.group:
        return 'members';
      case ChatScope.channel:
        return 'subscribers';
    }
  }
}
