import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:chat_app/core/models/conversation.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/members_provider.dart';
import '../../services/chat_repository.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({super.key, required this.conversation, required this.currentUserId});
  final ChatConversation conversation;
  final String currentUserId;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  List<UserModel> _allUsers = [];
  Map<String, UserModel> _userMap = {};
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final db = DatabaseService();
      final currentProfile = await db.loadUser(widget.currentUserId);
      final usersData = await db.fetchUsers(widget.currentUserId);
      final map = <String, UserModel>{};
      if (currentProfile != null) {
        final u = UserModel.fromMap(currentProfile);
        map[u.uid!] = u;
      }
      final list = <UserModel>[];
      if (usersData != null) {
        for (final data in usersData) {
          final u = UserModel.fromMap(data);
          list.add(u);
          map[u.uid!] = u;
        }
      }
      setState(() {
        _allUsers = list;
        _userMap = map;
        _loadingUsers = false;
      });
    } catch (e) {
      setState(() => _loadingUsers = false);
    }
  }

  void _showAddMemberDialog(BuildContext context, String groupId, Set<String> currentMemberIds) {
    final nonMembers = _allUsers.where((u) => !currentMemberIds.contains(u.uid)).toList();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Add Member', style: h.copyWith(color: primary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: nonMembers.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text('All contacts are already members', style: body.copyWith(color: grey), textAlign: TextAlign.center),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: nonMembers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final user = nonMembers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primary.withOpacity(0.1),
                        child: Text(user.name?[0].toUpperCase() ?? '', style: body.copyWith(color: primary)),
                      ),
                      title: Text(user.name ?? '', style: body.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('@${user.username}', style: small.copyWith(color: grey)),
                      onTap: () async {
                        Navigator.pop(dialogCtx);
                        try {
                          await ChatRepository().joinGroup(groupId, user.uid!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primary,
                              content: Text('${user.name} added successfully!', style: body.copyWith(color: white)),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to add member.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: body.copyWith(color: grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembersProvider(ChatRepository())..watch(ChatScope.group, widget.conversation.id),
      child: Consumer<MembersProvider>(builder: (context, provider, _) {
        final currentMemberIds = provider.members.map((m) => m.userId).toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Group Info'),
            centerTitle: true,
          ),
          body: _loadingUsers
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  children: [
                    // Group Header Card
                    Card(
                      elevation: 0,
                      color: grey.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundColor: primary.withOpacity(0.1),
                              child: Text(
                                widget.conversation.name?[0].toUpperCase() ?? 'G',
                                style: h.copyWith(color: primary, fontSize: 32.sp),
                              ),
                            ),
                            12.verticalSpace,
                            Text(widget.conversation.name ?? 'Group', style: h.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                            6.verticalSpace,
                            if (widget.conversation.description != null && widget.conversation.description!.isNotEmpty)
                              Text(
                                widget.conversation.description!,
                                style: body.copyWith(color: grey),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                    24.verticalSpace,

                    // Action buttons
                    ListTile(
                      leading: const Icon(Icons.person_add_rounded, color: primary),
                      title: Text('Add Member', style: body.copyWith(color: primary, fontWeight: FontWeight.bold)),
                      onTap: () => _showAddMemberDialog(context, widget.conversation.id, currentMemberIds),
                    ),
                    const Divider(),

                    // Members List Title
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                      child: Text(
                        '${provider.members.length} MEMBERS',
                        style: small.copyWith(color: grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),

                    // Members items
                    ...provider.members.map((m) {
                      final user = _userMap[m.userId];
                      final displayName = user?.name ?? m.userId;
                      final displayUsername = user != null ? '@${user.username}' : 'Loading...';
                      final isOwner = m.role == MemberRole.owner;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primary.withOpacity(0.05),
                          child: Text(displayName[0].toUpperCase(), style: body.copyWith(color: primary)),
                        ),
                        title: Text(displayName, style: body.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(displayUsername, style: small.copyWith(color: grey)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isOwner ? primary.withOpacity(0.1) : grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            isOwner ? 'Owner' : 'Member',
                            style: small.copyWith(
                              color: isOwner ? primary : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      );
                    }),
                    const Divider(),

                    // Leave Group button
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: primary),
                      title: Text('Leave Group', style: body.copyWith(color: primary, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        await ChatRepository().leaveGroup(widget.conversation.id, widget.currentUserId);
                        if (context.mounted) {
                          Navigator.popUntil(context, (r) => r.isFirst);
                        }
                      },
                    )
                  ],
                ),
        );
      }),
    );
  }
}
