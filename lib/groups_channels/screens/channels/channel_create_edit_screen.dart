import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_enums.dart';
import '../../providers/conversations_provider.dart';
import '../../services/chat_repository.dart';

class ChannelCreateEditScreen extends StatefulWidget {
  const ChannelCreateEditScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  State<ChannelCreateEditScreen> createState() => _ChannelCreateEditScreenState();
}

class _ChannelCreateEditScreenState extends State<ChannelCreateEditScreen> {
  final name = TextEditingController();
  final description = TextEditingController();
  ChannelPostingPolicy policy = ChannelPostingPolicy.adminsOnly;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationsProvider(ChatRepository()),
      child: Consumer<ConversationsProvider>(builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create Channel')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Channel name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: description, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<ChannelPostingPolicy>(
              value: policy,
              decoration: const InputDecoration(labelText: 'Posting permission', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: ChannelPostingPolicy.adminsOnly, child: Text('Admins only')),
                DropdownMenuItem(value: ChannelPostingPolicy.subscribers, child: Text('All subscribers')),
              ],
              onChanged: (v) => setState(() => policy = v ?? ChannelPostingPolicy.adminsOnly),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving ? null : () async {
                setState(() => saving = true);
                await provider.createChannel(ownerId: widget.currentUserId, name: name.text.trim(), description: description.text.trim(), postingPolicy: policy);
                if (mounted) Navigator.pop(context);
              },
              child: Text(saving ? 'Saving...' : 'Create'),
            ),
          ]),
        );
      }),
    );
  }
}
