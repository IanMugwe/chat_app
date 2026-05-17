import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(alignment: Alignment.centerLeft, child: Text('Typing...', style: TextStyle(fontStyle: FontStyle.italic))),
    );
  }
}
