import 'dart:io';
import 'dart:ui';
import 'package:chat_app/core/models/chat_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/user_model.dart';
import '../../core/services/database_service.dart';
import '../../core/services/chat_service.dart';
import '../../ui/screens/other/user_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import '../../core/providers/ui_theme_provider.dart';
import 'media_preview.dart';

class ForwardDestinationSheet extends StatefulWidget {
  final ChatMessage message;

  const ForwardDestinationSheet({super.key, required this.message});

  @override
  State<ForwardDestinationSheet> createState() => _ForwardDestinationSheetState();
}

class _ForwardDestinationSheetState extends State<ForwardDestinationSheet> {
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.uid ?? "";
      final databaseService = DatabaseService();
      final usersData = await databaseService.fetchUsers(currentUserId);
      if (usersData != null) {
        setState(() {
          _users = usersData.map((data) => UserModel.fromMap(data)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _forwardTo(BuildContext context, UserModel user) async {
    final chatService = ChatService();
    final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.uid ?? "";
    final currentUserName = Provider.of<UserProvider>(context, listen: false).user?.name ?? "";

    String chatRoomId = "";
    if (currentUserId.hashCode > user.uid!.hashCode) {
      chatRoomId = "${currentUserId}_${user.uid}";
    } else {
      chatRoomId = "${user.uid}_$currentUserId";
    }

    try {
      await chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: currentUserId,
        senderName: currentUserName,
        text: "[Forwarded]: ${widget.message.text ?? ''}",
        attachments: widget.message.attachments,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: primary,
          content: Text('Forwarded to ${user.name}!', style: body.copyWith(color: white)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to forward message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r)),
          ),
          16.verticalSpace,
          Text('Forward Message To', style: h.copyWith(color: primary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          16.verticalSpace,
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_users.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text('No contacts found', style: body.copyWith(color: grey)),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 0.4.sh),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primary.withOpacity(0.1),
                      child: Text(user.name?[0].toUpperCase() ?? '', style: body.copyWith(color: primary)),
                    ),
                    title: Text(user.name ?? '', style: body.copyWith(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.send_rounded, color: primary),
                    onTap: () => _forwardTo(context, user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

enum MessageActionType {
  star,
  pin,
  forward,
  delete,
  recreate,
  edit,
}

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeToReply({super.key, required this.child, required this.onReply});

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0.0;
  bool _hapticTriggered = false;
  static const double _threshold = -60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _dragOffset = _controller.value * _dragOffset;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! < 0 || _dragOffset < 0) {
      setState(() {
        _dragOffset += details.primaryDelta!;
        if (_dragOffset < -100.0) _dragOffset = -100.0;
        
        if (_dragOffset <= _threshold && !_hapticTriggered) {
          HapticFeedback.lightImpact();
          _hapticTriggered = true;
        } else if (_dragOffset > _threshold && _hapticTriggered) {
          _hapticTriggered = false;
        }
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset <= _threshold) {
      widget.onReply();
    }
    _hapticTriggered = false;
    _controller.value = 1.0;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (_dragOffset < 0)
            Positioned(
              right: 16.w,
              child: Opacity(
                opacity: (_dragOffset / -100.0).clamp(0.0, 1.0),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.reply_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class MessageActionDialog extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isAiChat;
  final Function(MessageActionType type) onAction;

  const MessageActionDialog({
    super.key,
    required this.message,
    required this.isMine,
    required this.isAiChat,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 8,
      backgroundColor: white,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Options',
              style: h.copyWith(color: primary, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            12.verticalSpace,
            _buildActionItem(
              icon: message.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              title: message.isStarred ? 'Unstar Message' : 'Star Message',
              type: MessageActionType.star,
            ),
            _buildActionItem(
              icon: message.isPinned ? Icons.pin_drop_rounded : Icons.push_pin_rounded,
              title: message.isPinned ? 'Unpin Message' : 'Pin Message',
              type: MessageActionType.pin,
            ),
            _buildActionItem(
              icon: Icons.shortcut_rounded,
              title: 'Forward Message',
              type: MessageActionType.forward,
            ),
            if (isMine)
              _buildActionItem(
                icon: Icons.edit_rounded,
                title: 'Edit Message',
                type: MessageActionType.edit,
              ),
            if (isMine)
              _buildActionItem(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Message',
                type: MessageActionType.delete,
              ),
            if (isAiChat)
              _buildActionItem(
                icon: Icons.refresh_rounded,
                title: 'Recreate Response',
                type: MessageActionType.recreate,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required MessageActionType type,
  }) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: primary),
        title: Text(title, style: body.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
        onTap: () {
          Navigator.pop(context);
          onAction(type);
        },
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    this.onStar,
    this.onPin,
    this.onForward,
    this.onRecreate,
    this.isAiChat = false,
    this.onReact,
  });

  final ChatMessage message;
  final bool isMine;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onStar;
  final VoidCallback? onPin;
  final VoidCallback? onForward;
  final VoidCallback? onRecreate;
  final bool isAiChat;
  final void Function(String emoji)? onReact;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isHighlighted = false;

  void _showMenu(BuildContext context) {
    setState(() => _isHighlighted = true);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => MessageActionDialog(
        message: widget.message,
        isMine: widget.isMine,
        isAiChat: widget.isAiChat,
        onAction: (type) {
          switch (type) {
            case MessageActionType.star:
              widget.onStar?.call();
              break;
            case MessageActionType.pin:
              widget.onPin?.call();
              break;
            case MessageActionType.forward:
              widget.onForward?.call();
              break;
            case MessageActionType.edit:
              widget.onEdit();
              break;
            case MessageActionType.delete:
              widget.onDelete();
              break;
            case MessageActionType.recreate:
              widget.onRecreate?.call();
              break;
          }
        },
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isHighlighted = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    final bg = widget.isMine ? (active.isDark ? const Color(0xFF1F1E24) : const Color(0xFF23222A)) : active.otherBubbleColor;
    final textStyle = body.copyWith(
      color: widget.isMine 
          ? Colors.white 
          : (active.isDark ? Colors.white : Colors.black87),
      fontSize: 14.sp,
    );

    String getTimeString(DateTime dt) {
      final hr = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hr:${dt.minute.toString().padLeft(2, '0')}$ampm';
    }

    final bool hasMedia = widget.message.type == MessageType.image || widget.message.type == MessageType.video || widget.message.type == MessageType.file || widget.message.attachments.isNotEmpty;

    Widget bubbleBody = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: widget.isMine
            ? bg
            : bg.withOpacity(active.isDark ? 0.35 : 0.85),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(widget.isMine ? 18.r : 6.r),
          bottomRight: Radius.circular(widget.isMine ? 6.r : 18.r),
        ),
        border: widget.isMine
            ? null
            : Border.all(
                color: active.primaryAccent.withOpacity(hasMedia ? 0.02 : 0.12),
                width: 1,
              ),
      ),
      constraints: BoxConstraints(maxWidth: 1.sw * 0.72),
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isMine && widget.message.senderName != null)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  widget.message.senderName!,
                  style: small.copyWith(
                    fontWeight: FontWeight.bold,
                    color: active.primaryAccent,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            if (widget.message.replyPreview != null)
              Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: widget.isMine ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.message.replyPreview!,
                  style: body.copyWith(
                    fontSize: 12.sp,
                    color: widget.isMine ? Colors.white : (active.isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            if (widget.message.isDeleted)
              Text(
                'This message was deleted',
                style: body.copyWith(
                  fontStyle: FontStyle.italic,
                  color: widget.isMine ? Colors.white70 : (active.isDark ? Colors.white54 : Colors.black54),
                ),
              )
            else ...[
              if (widget.message.type == MessageType.text && widget.message.text != null)
                Text(
                  widget.message.text!,
                  style: textStyle,
                )
              else if (widget.message.type == MessageType.image && widget.message.text != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: GestureDetector(
                    onTap: () {
                      // Support tap to preview/fullscreen
                    },
                    child: (widget.message.text!.startsWith('http://') || widget.message.text!.startsWith('https://'))
                      ? Image.network(
                          widget.message.text!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 150.h,
                              width: 150.w,
                              color: Colors.grey.withOpacity(0.2),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150.h,
                            width: 150.w,
                            color: Colors.grey.withOpacity(0.2),
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Image.file(
                          File(widget.message.text!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150.h,
                            width: 150.w,
                            color: Colors.grey.withOpacity(0.2),
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                  ),
                )
              else if (widget.message.type == MessageType.video && widget.message.text != null)
                GestureDetector(
                  onTap: () {
                    // Support tap to play
                  },
                  child: Container(
                    height: 150.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50.r),
                    ),
                  ),
                )
              else if (widget.message.type == MessageType.file && widget.message.attachments.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Tap to download/open
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: widget.isMine ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file, color: widget.isMine ? Colors.white : active.primaryAccent),
                        8.horizontalSpace,
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.message.attachments.first.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: body.copyWith(
                                  color: widget.isMine ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(widget.message.attachments.first.sizeBytes / 1024).toStringAsFixed(1)} KB',
                                style: small.copyWith(
                                  color: widget.isMine ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (widget.message.attachments != null && widget.message.attachments.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: MediaPreview(attachments: widget.message.attachments, isOutgoing: widget.isMine),
                ),
            ],
            if (widget.message.reactions.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Wrap(
                  spacing: 4,
                  children: widget.message.reactions.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => GestureDetector(
                            onTap: () => widget.onReact?.call(e.key),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: widget.isMine ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${e.key} ${e.value.length}',
                                style: body.copyWith(fontSize: 10.sp, color: widget.isMine ? Colors.white : (active.isDark ? Colors.white70 : Colors.black54)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],        // closes Column's children list
        ),          // ← ADD THIS: closes the Column widget itself
        if (widget.message.status == MessageStatus.sending &&    // 2nd Stack child
              (widget.message.type == MessageType.image || widget.message.type == MessageType.video || widget.message.type == MessageType.file))
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    ));

    return SwipeToReply(
      onReply: widget.onReply,
      child: Align(
        alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: widget.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (widget.message.createdAt != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h, left: 4.w, right: 4.w),
                  child: Text(
                    "${getTimeString(widget.message.createdAt!)}${widget.message.isEdited ? ' (edited)' : ''}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: active.isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              GestureDetector(
                onLongPress: () => _showMenu(context),
                child: widget.isMine
                    ? bubbleBody
                    : ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.r),
                          topRight: Radius.circular(18.r),
                          bottomLeft: Radius.circular(6.r),
                          bottomRight: Radius.circular(18.r),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: bubbleBody,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
