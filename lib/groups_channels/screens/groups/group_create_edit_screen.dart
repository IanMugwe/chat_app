import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversations_provider.dart';
import '../../services/chat_repository.dart';

class GroupCreateEditScreen extends StatefulWidget {
  const GroupCreateEditScreen({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  State<GroupCreateEditScreen> createState() => _GroupCreateEditScreenState();
}

class _GroupCreateEditScreenState extends State<GroupCreateEditScreen> {
  final name = TextEditingController();
  final description = TextEditingController();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationsProvider(ChatRepository()),
      child: Consumer<ConversationsProvider>(builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create Group')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Group name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: description, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving ? null : () async {
                setState(() => saving = true);
                await provider.createGroup(ownerId: widget.currentUserId, name: name.text.trim(), description: description.text.trim(), memberIds: []);
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
