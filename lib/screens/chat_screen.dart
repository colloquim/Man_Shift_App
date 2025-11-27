// screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final OpenAIService ai;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // NOW USING YOUR MESSAGE MODEL
  final List<Message> messages = [];

  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    ai = OpenAIService();

    // Initial AI message using Message model
    messages.add(
      Message(
        sender: "ai",
        type: "system",
        text:
            "Hi there! I'm here to provide guidance and support around gender-based violence (GBV), healthy relationships, and creating safe spaces both online and offline. How can I support you today?",
      ),
    );
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    _controller.clear();

    // Add USER message
    setState(() {
      messages.add(
        Message(
          sender: "user",
          text: userText,
        ),
      );
      isTyping = true;
    });

    _scrollToBottom();

    String reply =
        "Something went wrong. Please try again or check your internet connection.";

    try {
      reply = await ai.askManshiftAI(userText);
    } catch (e) {
      print("MANSHIFT AI ERROR → $e");
    }

    // Add AI REPLY
    setState(() {
      messages.add(
        Message(
          sender: "ai",
          text: reply,
        ),
      );
      isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MANSHIFT AI Mentor"),
        backgroundColor: const Color(0xFF00A8A8),
      ),
      body: Column(
        children: [
          // ⚠️ UPDATED SAFETY DISCLAIMER
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.red.shade50,
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Important: MANSHIFT provides guidance on GBV awareness, healthy masculinity, and respectful relationships. It cannot replace professional help. If you are facing violence, threats, or feel unsafe, please contact professionals or emergency services immediately.",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // MESSAGES LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF00A8A8)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // TYPING INDICATOR
          if (isTyping)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "MANSHIFT is responding…",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

          // INPUT FIELD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => isTyping ? null : sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Type your message…",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF00A8A8),
                  onPressed: isTyping ? null : sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
