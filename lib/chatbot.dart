
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      print("Refresh token not found");
      return false;
    }

    final url = Uri.parse('http://56.228.80.139/api/token/refresh/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      await prefs.setString('authToken', newAccessToken);
      print("✅ Access token refreshed");
      return true;
    } else {
      print("❌ Failed to refresh token: ${response.body}");
      return false;
    }
  }

  Future<String?> sendMessageToBot(String message) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) return null;

    final url = Uri.parse('http://56.228.80.139/api/chatbot/messages/create/');

    Future<http.Response> _sendRequest(String token) {
      return http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': message,
          'chat_model_id': 2,
        }),
      );
    }

    http.Response response = await _sendRequest(token);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['messages']['ai']['content'];
    } else if (response.statusCode == 401) {
      print("⚠️ Token expired, trying to refresh...");
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        token = prefs.getString('authToken');
        response = await _sendRequest(token!);
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          return data['messages']['ai']['content'];
        }
      }
    } else {
      print("❌ API Error: ${response.statusCode} => ${response.body}");
    }

    return null;
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
      _controller.clear();
    });

    final botResponse = await sendMessageToBot(text);

    setState(() {
      if (botResponse != null) {
        _messages.add({"role": "bot", "content": botResponse});
      } else {
        _messages.add({"role": "bot", "content": "Failed to get response. Try again."});
      }
      _isLoading = false;
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final content = msg['content'] ?? '';

    // Split content by ** for bold text
    final regex = RegExp(r"\*\*(.*?)\*\*");
    final spans = <TextSpan>[];
    int start = 0;

    for (final match in regex.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(text: content.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }

    if (start < content.length) {
      spans.add(TextSpan(text: content.substring(start)));
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("StudyGPT Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
