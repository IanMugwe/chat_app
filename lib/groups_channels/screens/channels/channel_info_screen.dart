import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import '../../providers/members_provider.dart';
import '../../services/chat_repository.dart';

class ChannelInfoScreen extends StatelessWidget {
  const ChannelInfoScreen({super.key, required this.conversation, required this.currentUserId});
  final ChatConversation conversation;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembersProvider(ChatRepository())..watch(ChatScope.channel, conversation.id),
      child: Consumer<MembersProvider>(builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Channel Info')),
          body: ListView(children: [
            ListTile(title: Text(conversation.name ?? 'Channel'), subtitle: Text(conversation.description ?? '')),
            ListTile(title: Text('${conversation.count} subscribers')),
            ListTile(title: const Text('Posting policy'), subtitle: Text(conversation.postingPolicy.name)),
            const Divider(),
            ...provider.members.map((m) => ListTile(title: Text(m.userId), subtitle: Text(m.role.name))),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Unsubscribe'),
              onTap: () async { await ChatRepository().unsubscribeChannel(conversation.id, currentUserId); if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst); },
            )
          ]),
        );
      }),
    );
  }
}
