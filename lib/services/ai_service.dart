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
                "You are Synthe, a calm, focused AI assistant inside a productivity app.",
          },
          {"role": "user", "content": message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
