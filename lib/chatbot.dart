// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final List<Map<String, String>> _messages = []; // {'role': 'user' or 'bot', 'text': ''}
//   final TextEditingController _controller = TextEditingController();
//   bool _isLoading = false;
//
//   void _sendMessage() async {
//     final inputText = _controller.text.trim();
//     if (inputText.isEmpty || _isLoading) return;
//
//     setState(() {
//       _messages.add({'role': 'user', 'text': inputText});
//       _controller.clear();
//       _isLoading = true;
//     });
//
//     try {
//       // TODO: Replace with API
//       final responseText = await sendToLLMBackend(inputText);
//
//       setState(() {
//         _messages.add({'role': 'bot', 'text': responseText});
//       });
//     } catch (e) {
//       setState(() {
//         _messages.add({'role': 'bot', 'text': 'Error: Could not fetch response.'});
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<String> sendToLLMBackend(String message) async {
//     final url = Uri.parse('http://56.228.80.139/api/chatbot/messages/create/'); // Your API endpoint
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({'message': message}),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['response'] != null) {
//         return data['response'];
//       } else {
//         throw Exception('Malformed response');
//       }
//     } else {
//       throw Exception('Failed to connect: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('StudyGPT AI Chat'),
//         backgroundColor: Colors.teal.shade600,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               reverse: true,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[_messages.length - 1 - index];
//                 final isUser = msg['role'] == 'user';
//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.all(12),
//                     constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(msg['text']!, style: const TextStyle(fontSize: 15)),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8),
//               child: CircularProgressIndicator(),
//             ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: (_) => _sendMessage(),
//                     decoration: InputDecoration(
//                       hintText: 'Ask something...',
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: const Icon(Icons.send_rounded),
//                   color: Colors.teal,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
  @override
  void initState() {
    super.initState();
    loadPreviousConversations();
  }


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
  Future<void> loadPreviousConversations() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) return;

    final url = Uri.parse('http://56.228.80.139/api/chatbot/messages/6');

    http.Response response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print("🔁 Raw response: ${response.body}");

      final List<dynamic> messages = data['messages'];

      setState(() {
        _messages.clear();

        for (var msg in messages) {
          _messages.add({
            'role': msg['sender'],   // either 'user' or 'ai'
            'content': msg['content'],
          });
        }
      });
    } else {
      print("❌ Failed to load chats: ${response.statusCode}");
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
          'chat_model_id': 2, // Always use chatbot 2
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg['content'] ?? '[No message content]'),

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
