import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import '../../providers/conversations_provider.dart';
import '../../services/chat_repository.dart';
import '../../widgets/conversation_tile.dart';
import '../shared/chat_screen.dart';
import 'group_create_edit_screen.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key, required this.currentUserId, required this.currentUserName});
  final String currentUserId;
  final String currentUserName;

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ConversationsProvider>().watch(widget.currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: provider.groups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = provider.groups[i];
                return ConversationTile(
                  conversation: c,
                  currentUserId: widget.currentUserId,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    scope: ChatScope.group,
                    conversation: c,
                    currentUserId: widget.currentUserId,
                    currentUserName: widget.currentUserName,
                    repository: ChatRepository(),
                  ))),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group_add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupCreateEditScreen(currentUserId: widget.currentUserId))),
      ),
    );
  }
}
