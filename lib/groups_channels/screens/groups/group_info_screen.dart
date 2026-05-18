import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import '../../providers/members_provider.dart';
import '../../services/chat_repository.dart';

class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key, required this.conversation, required this.currentUserId});
  final ChatConversation conversation;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembersProvider(ChatRepository())..watch(ChatScope.group, conversation.id),
      child: Consumer<MembersProvider>(builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Group Info')),
          body: ListView(children: [
            ListTile(title: Text(conversation.name ?? 'Group'), subtitle: Text(conversation.description ?? '')),
            ListTile(title: Text('${conversation.count} members')),
            const Divider(),
            ...provider.members.map((m) => ListTile(title: Text(m.userId), subtitle: Text(m.role.name))),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Leave group'),
              onTap: () async { await ChatRepository().leaveGroup(conversation.id, currentUserId); if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst); },
            )
          ]),
        );
      }),
    );
  }
}
