import 'package:flutter/material.dart';

/// Self-contained message composer bar.
/// Emits callbacks for send, image pick, file pick, audio record.
/// Emoji sheet toggling is handled locally.
class MessageComposer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;
  final VoidCallback? onImagePick;
  final VoidCallback? onFilePick;
  final VoidCallback? onAudioRecord;
  final VoidCallback? onCameraPick;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onChanged,
    this.onImagePick,
    this.onFilePick,
    this.onAudioRecord,
    this.onCameraPick,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  bool _hasText = false;
  bool _showAttachMenu = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    widget.onChanged(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showAttachMenu) _buildAttachMenu(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment toggle
                _IconBtn(
                  icon: _showAttachMenu ? Icons.close_rounded : Icons.add_rounded,
                  onTap: () => setState(() => _showAttachMenu = !_showAttachMenu),
                ),
                const SizedBox(width: 6),
                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 15),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Send or mic
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? _SendBtn(key: const ValueKey('send'), onTap: widget.onSend)
                      : _IconBtn(
                          key: const ValueKey('mic'),
                          icon: Icons.mic_none_rounded,
                          onTap: widget.onAudioRecord,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AttachOption(icon: Icons.image_rounded, label: 'Photo', color: const Color(0xFF7C6FF7), onTap: () {
            setState(() => _showAttachMenu = false);
            widget.onImagePick?.call();
          }),
          _AttachOption(icon: Icons.insert_drive_file_rounded, label: 'File', color: const Color(0xFF3B82F6), onTap: () {
            setState(() => _showAttachMenu = false);
            widget.onFilePick?.call();
          }),
          _AttachOption(icon: Icons.camera_alt_rounded, label: 'Camera', color: const Color(0xFF10B981), onTap: () {
            setState(() => _showAttachMenu = false);
            widget.onCameraPick?.call();
          }),
          _AttachOption(icon: Icons.location_on_rounded, label: 'Location', color: const Color(0xFFF59E0B), onTap: () {
            setState(() => _showAttachMenu = false);
          }),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
}

class _SendBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SendBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
        ),
      );
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      );
}
