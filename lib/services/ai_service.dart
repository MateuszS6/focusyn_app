import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const _apiKey =
      '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';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static Future<String> askSynthe(String message) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content":
                "You are Synthe, a supportive and motivating AI guide inside a productivity app called Focusyn.\n\n"
                "Your goal is to help users stay focused, reflect, and organize their thoughts into Actions, Flows, Moments, or Thoughts.\n"
                "- Use a warm, uplifting tone.\n"
                "- Keep replies short and conversational.\n"
                "- Use emojis to add emotion and clarity (like 😊, ✅, 📅, 💭, 🔁).\n"
                "- If the user expresses an idea, suggest adding it to a Focus (e.g. 'That sounds like a Flow 🔁' or 'Want to save that as a Thought? 💭').\n"
                "- If they’re struggling, encourage gently (‘Start small 💡’ or ‘Just one step today 💪’).\n"
                "- Never sound robotic or over-explain. Just be clear and kind.",
          },
          {"role": "user", "content": message},
        ],
      }),
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
