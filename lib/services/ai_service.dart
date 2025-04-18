import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const _apiKey =
      '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';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  // Approximate token limit for gpt-3.5-turbo
  static const _maxTokens = 4096;
  // Keep some room for the response
  static const _reservedTokens = 1000;

  // Rough token estimation (this is approximate)
  static int _estimateTokens(String text) {
    // GPT models typically use ~4 chars per token
    return (text.length / 4).ceil();
  }

  static List<Map<String, String>> _pruneMessages(
    List<Map<String, String>> messages,
  ) {
    int totalTokens = 0;
    // Start from most recent (excluding system message)
    for (int i = messages.length - 1; i >= 1; i--) {
      totalTokens += _estimateTokens(messages[i]['content'] ?? '');

      // If we exceed token limit, remove older messages
      if (totalTokens > _maxTokens - _reservedTokens) {
        return [
          messages[0], // Keep system message
          ...messages.sublist(i), // Keep only recent messages
        ];
      }
    }
    return messages;
  }

  static Future<String> askSynthe(
    String message,
    List<Map<String, dynamic>> chatHistory,
  ) async {
    final List<Map<String, String>> messages = [
      {
        "role": "system",
        "content":
            "You are Synthe, a supportive and motivating AI guide inside a productivity app called Focusyn.\n\n"
            "Your goal is to help users stay focused, reflect, and organize their thoughts into Actions, Flows, Moments, or Thoughts.\n"
            "- Use a warm, uplifting tone.\n"
            "- Keep replies short and conversational.\n"
            "- Use emojis to add emotion and clarity (like 😊, ✅, 📅, 💭, 🔁).\n"
            "- If the user expresses an idea, suggest adding it to a Focus (e.g. 'That sounds like a Flow 🔁' or 'Want to save that as a Thought? 💭').\n"
            "- If they're struggling, encourage gently ('Start small 💡' or 'Just one step today 💪').\n"
            "- Never sound robotic or over-explain. Just be clear and kind.",
      },
      ...chatHistory.map(
        (msg) => {
          "role": msg['isUser'] ? "user" : "assistant",
          "content": msg['text'] as String,
        },
      ),
      {"role": "user", "content": message},
    ];

    // Prune messages if they exceed token limit
    final prunedMessages = _pruneMessages(messages);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({"model": "gpt-3.5-turbo", "messages": prunedMessages}),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);

      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
