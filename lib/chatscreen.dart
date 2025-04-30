// chat_screen_with_scroll.dart
import 'package:flutter/material.dart';

class ChatScreenWithScroll extends StatefulWidget {
  final ScrollController scrollController;

  const ChatScreenWithScroll({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<ChatScreenWithScroll> createState() => _ChatScreenWithScrollState();
}

class _ChatScreenWithScrollState extends State<ChatScreenWithScroll> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage() async {
    final inputText = _controller.text.trim();
    if (inputText.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': inputText});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final responseText = await sendToLLMBackend(inputText);
      setState(() {
        _messages.add({'role': 'bot', 'text': responseText});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Error: Could not fetch response.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> sendToLLMBackend(String message) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Mock reply to: \"$message\"";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 6,
          width: 50,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(12),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(msg['text']!, style: const TextStyle(fontSize: 15)),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask something...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded),
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
