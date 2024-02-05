import 'dart:convert';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/utils/export_utils.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String? prompt;

  const ChatPage({Key? key, required this.prompt}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isSend = true;
  String username = "Clinton";
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  @override
  void initState() {
    super.initState();

    print(widget.prompt);
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _sendMessage(String content) async {
    const apiUrl = 'http://34.28.14.249/api/chat';
    final payload = {
      "messages": [
        {
          "role": "user",
          "content": "hi",
        },
        {
          "role": "assistant",
          "content": 'Assalamu Alaikum!, How can I help you today',
        },
        {
          "role": "user",
          "content": content,
        }
      ],
      "userName": ""
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final translatedText = jsonResponse['translatedText'];

      final message = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: translatedText,
      );

      _addMessage(message);
    } else {
      // Handle error
      print('Error sending message: ${response.statusCode}');
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    // Create a temporary message for optimistic UI update
    final optimisticMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    // Add the temporary message to the UI
    _addMessage(optimisticMessage);

    try {
      // Send the actual message to the API
      await _sendMessage(message.text);
    } catch (e) {
      // Handle the error, for example, show an error message to the user
      print('Error sending message: $e');

      // Remove the temporary message from the UI in case of an error
      setState(() {
        _messages.remove(optimisticMessage);
      });
    }
  }

  void _loadMessages() async {
    // Load initial messages from a local source or initial API call
    // ...

    // For demonstration purposes, I'm using a static list of messages
    final initialMessages = [
      types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text:
            "Assalamu Alaikum! I am your AI guide for prayer devotion and in reading Quran . How may I assist you today?",
      ),
    ];

    setState(() {
      _messages = initialMessages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          inputOptions: InputOptions(
              sendButtonVisibilityMode: SendButtonVisibilityMode.always,
              textEditingController: TextEditingController(
                  text:
                      'Explain does Allah teaches overcoming ${widget.prompt}?,')),
          onSendPressed: isSend! ? _handleSendPressed : (p0) {},
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          bubbleBuilder: (child,
              {required message, required nextMessageInGroup}) {
            final bool isSent = message.author.id == _user.id;
            return Bubble(
              margin: BubbleEdges.only(top: 10),
              alignment: isSent ? Alignment.topRight : Alignment.topLeft,
              nip: isSent ? BubbleNip.rightTop : BubbleNip.leftTop,
              color: isSent ? Colors.blue : Colors.teal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: isSent ? Colors.black : Colors.white,
                  ),
                  child: child,
                ),
              ),
            );
          },
          theme: DarkChatTheme(
              inputElevation: 3,
              // messageInsetsHorizontal: 50.0,
              
              primaryColor: Colors.teal,
              systemMessageTheme: SystemMessageTheme(
                  margin: EdgeInsets.all(8), textStyle: TextStyle())),
        ),
      );
}
