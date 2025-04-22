import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// A service class for interacting with OpenAI's GPT API.
/// This service provides:
/// - Chat completion functionality
/// - Message history management
/// - Token limit handling
/// - Context-aware responses
class AIService {
  /// OpenAI API key for authentication
  static final _apiKey = dotenv.env['OPENAI_API_KEY'];

  /// OpenAI API endpoint for chat completions
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  /// Maximum token limit for GPT-3.5-turbo model
  static const _maxTokens = 4096;

  /// Reserved tokens for the model's response
  static const _reservedTokens = 1000;

  /// Estimates the number of tokens in a text string.
  /// This method uses an approximate calculation based on the average
  /// number of characters per token in GPT models.
  ///
  /// [text] - The text to estimate tokens for
  /// Returns the estimated number of tokens
  static int _estimateTokens(String text) {
    // GPT models typically use ~4 chars per token
    return (text.length / 4).ceil();
  }

  /// Prunes message history to fit within token limits.
  /// This method:
  /// - Preserves the system message
  /// - Keeps the most recent messages
  /// - Removes older messages if needed
  ///
  /// [messages] - List of message objects to prune
  /// Returns a pruned list of messages that fits within token limits
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

  /// Sends a message to the AI and gets a response.
  /// This method:
  /// - Constructs a context-aware system prompt
  /// - Manages chat history
  /// - Handles token limits
  /// - Processes the AI response
  ///
  /// [message] - The user's message to send
  /// [chatHistory] - Previous conversation history
  /// [chatContext] - Additional context about the user
  ///
  /// Returns the AI's response as a string
  ///
  /// Throws an exception if:
  /// - API request fails
  /// - Response parsing fails
  static Future<String> askAI(
    String message,
    List<Map<String, dynamic>> chatHistory, {
    Map<String, dynamic>? chatContext = const {},
  }) async {
    // Extract context information
    final userName = chatContext?['userName'] ?? 'user';
    final brainPoints = chatContext?['brainPoints'] ?? 100;
    final tasks = (chatContext?['tasks'] as List<String>?) ?? [];

    // Construct system prompt with user context
    // Note: The initial system prompt was generated with assistance from genAI,
    // while the definitions were added by the developer to clarify key concepts
    final systemPrompt = '''
    You are Synthe, a calm, supportive, and motivating AI guide inside a productivity app called Focusyn.
     - The user's name is $userName.
     - They currently have $brainPoints brain points.
     - Their current task list includes: $tasks.

    Your goal is to help users stay focused, reflect, and organize their thoughts into Actions, Flows, Moments, or Thoughts.
    It is also to give habit recommendations based on the user's task list.

    Definitions:
    - Action: A single task that the user wants to complete.
    - Flow: A routine or habit that the user wants to develop and track.
    - Moment: A single event or deadline that the user wants to plan for.
    - Thought: A reflection or idea that the user wants to remember.
    - Brain Points: A mental energy score that the user depletes by completing tasks, which resets daily to 100.
    - Focus: A collection of Actions, Flows, Moments, or Thoughts.

    Use friendly tone, emojis (✅, 💡, 🔁, 💭), and keep responses short and supportive.
    ''';

    // Construct message list with system prompt and history
    final List<Map<String, String>> messages = [
      {"role": "system", "content": systemPrompt},
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

    // Send request to OpenAI API
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({"model": "gpt-3.5-turbo", "messages": prunedMessages}),
    );

    if (response.statusCode == 200) {
      // Parse and return the AI's response
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
