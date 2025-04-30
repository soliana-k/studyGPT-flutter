// draggable_chat_sheet.dart
import 'package:flutter/material.dart';
import 'chatscreen.dart'; // import the next component

class DraggableChatSheet extends StatelessWidget {
  const DraggableChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ChatScreenWithScroll(scrollController: scrollController),
        );
      },
    );
  }
}
