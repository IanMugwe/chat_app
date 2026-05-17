import '../models/chat_enums.dart';

class ChatPaths {
  static String collectionFor(ChatScope scope) {
    switch (scope) {
      case ChatScope.direct:
        return 'directChats';
      case ChatScope.group:
        return 'groups';
      case ChatScope.channel:
        return 'channels';
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
