import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/chat_message.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';
import 'media_preview.dart';

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
    final bg = widget.isMine ? primary : grey.withOpacity(0.12);
    return SwipeToReply(
      onReply: widget.onReply,
      child: Align(
        alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () => _showMenu(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: _isHighlighted ? bg.withOpacity(widget.isMine ? 0.8 : 0.25) : bg,
              borderRadius: BorderRadius.circular(16.r),
              border: _isHighlighted
                  ? Border.all(color: primary.withOpacity(0.5), width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.message.replyPreview != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: widget.isMine ? white.withOpacity(0.15) : Colors.black.withOpacity(.05),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      widget.message.replyPreview!,
                      style: body.copyWith(
                        fontSize: 12.sp,
                        color: widget.isMine ? white : Colors.black87,
                      ),
                    ),
                  ),
                if (widget.message.isDeleted)
                  Text(
                    'This message was deleted',
                    style: body.copyWith(
                      fontStyle: FontStyle.italic,
                      color: widget.isMine ? white : Colors.black54,
                    ),
                  )
                else ...[
                  if (widget.message.text != null)
                    Text(
                      widget.message.text!,
                      style: body.copyWith(
                        color: widget.isMine ? white : Colors.black87,
                      ),
                    ),
                  if (widget.message.attachments != null && widget.message.attachments.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: MediaPreview(attachments: widget.message.attachments, isOutgoing: widget.isMine),
                    ),
                ],
                if (widget.message.isStarred || widget.message.isPinned)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.message.isStarred)
                          Icon(Icons.star_rounded, size: 14.r, color: widget.isMine ? white : primary),
                        if (widget.message.isStarred && widget.message.isPinned)
                          4.horizontalSpace,
                        if (widget.message.isPinned)
                          Icon(Icons.push_pin_rounded, size: 14.r, color: widget.isMine ? white : primary),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
