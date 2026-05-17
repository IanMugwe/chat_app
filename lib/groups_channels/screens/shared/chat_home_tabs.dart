import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversations_provider.dart';
import '../../services/chat_repository.dart';
import '../groups/groups_list_screen.dart';
import '../channels/channels_list_screen.dart';

class ChatHomeTabs extends StatelessWidget {
  const ChatHomeTabs({super.key, required this.currentUserId, required this.currentUserName});
  final String currentUserId;
  final String currentUserName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationsProvider(ChatRepository()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('YohPal Chat'),
            bottom: const TabBar(tabs: [Tab(text: 'Groups'), Tab(text: 'Channels')]),
          ),
          body: TabBarView(children: [
            GroupsListScreen(currentUserId: currentUserId, currentUserName: currentUserName),
            ChannelsListScreen(currentUserId: currentUserId, currentUserName: currentUserName),
          ]),
        ),
      ),
    );
  }
}
