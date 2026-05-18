import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isAi': true,
      'text': 'Hello! I am your yCHAT AI assistant. How can I help you today?',
      'time': 'Just now',
    }
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'isAi': false,
        'text': text,
        'time': 'Just now',
      });
      _controller.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isAi': true,
          'text': 'This is a premium yCHAT AI simulation. Full intelligence capabilities are coming in the next release!',
          'time': 'Just now',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: primary),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primary.withOpacity(0.1),
              radius: 18.r,
              child: const Icon(Icons.auto_awesome, color: primary, size: 20),
            ),
            12.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'yCHAT AI',
                  style: h.copyWith(fontSize: 16.sp, color: primary),
                ),
                Text(
                  'Online',
                  style: small.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              reverse: true,
              itemCount: _messages.length,
              separatorBuilder: (_, __) => 12.verticalSpace,
              itemBuilder: (context, index) {
                // Reverse index because ListView is reverse
                final m = _messages[_messages.length - 1 - index];
                final isAi = m['isAi'] as bool;
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 1.sw * 0.75),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isAi ? grey.withOpacity(0.1) : primary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      m['text'] as String,
                      style: body.copyWith(
                        color: isAi ? Colors.black87 : white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              bottom: 25.h,
            ),
            color: white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask yCHAT AI...',
                      hintStyle: body.copyWith(color: grey),
                      filled: true,
                      fillColor: grey.withOpacity(0.08),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                12.horizontalSpace,
                CircleAvatar(
                  backgroundColor: primary,
                  radius: 22.r,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
