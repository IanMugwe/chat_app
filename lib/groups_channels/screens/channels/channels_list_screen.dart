import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_enums.dart';
import '../../providers/conversations_provider.dart';
import '../../services/chat_repository.dart';
import '../../widgets/conversation_tile.dart';
import '../shared/chat_screen.dart';
import 'channel_create_edit_screen.dart';

class ChannelsListScreen extends StatefulWidget {
  const ChannelsListScreen({super.key, required this.currentUserId, required this.currentUserName});
  final String currentUserId;
  final String currentUserName;

  @override
  State<ChannelsListScreen> createState() => _ChannelsListScreenState();
}

class _ChannelsListScreenState extends State<ChannelsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ConversationsProvider>().watch(widget.currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: provider.channels.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = provider.channels[i];
                return ConversationTile(
                  conversation: c,
                  currentUserId: widget.currentUserId,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    scope: ChatScope.channel,
                    conversation: c,
                    currentUserId: widget.currentUserId,
                    currentUserName: widget.currentUserName,
                    repository: ChatRepository(),
                  ))),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChannelCreateEditScreen(currentUserId: widget.currentUserId))),
      ),
    );
  }
}
