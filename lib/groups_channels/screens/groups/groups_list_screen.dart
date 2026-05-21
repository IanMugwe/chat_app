import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'groups',
          style: h.copyWith(
            color: active.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 26.sp,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: provider.loading
            ? Center(child: CircularProgressIndicator(color: active.primaryAccent))
            : provider.groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 48.r, color: active.isDark ? Colors.white38 : Colors.black38),
                        16.verticalSpace,
                        Text("No groups joined yet", style: body.copyWith(fontWeight: FontWeight.bold, color: active.isDark ? Colors.white : Colors.black87)),
                        8.verticalSpace,
                        Text("Tap the + button to create or join a group.", style: small.copyWith(color: active.isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: provider.groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: active.primaryAccent,
        child: const Icon(Icons.group_add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupCreateEditScreen(currentUserId: widget.currentUserId))),
      ),
    );
  }
}
