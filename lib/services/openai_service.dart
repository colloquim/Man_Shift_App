// services/openai_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = dotenv.env["OPENAI_API_KEY"] ?? "";

  // 1. New: Store conversation history in a list of maps
  final List<Map<String, String>> messageHistory = [
    // 2. Initial System Prompt (Sets the AI's personality and role)
    {
      "role": "system",
      "content":
          "You are MANSHIFT, an AI mentor teaching emotional intelligence, respect, and healthy masculinity. Your tone is supportive and non-judgmental. Keep responses concise and focused on positive change.",
    },
  ];

  Future<String> askManshiftAI(String message) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    // 3. Add the new user message to the history before sending
    messageHistory.add({"role": "user", "content": message});

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        // 4. Send the entire message history
        "messages": messageHistory,
        "temperature": 0.8,
      }),
    );

    // print("RAW RESPONSE: ${response.body}"); // Commented out for cleaner console

    if (response.statusCode != 200) {
      // 5. Important: Remove the last user message if API fails
      messageHistory.removeLast();
      return "Something went wrong (code ${response.statusCode})";
    }

    final data = jsonDecode(response.body);
    final aiReply = data["choices"][0]["message"]["content"];

    // 6. Add the successful AI reply to the history
    messageHistory.add({"role": "assistant", "content": aiReply});

    return aiReply;
  }
}
