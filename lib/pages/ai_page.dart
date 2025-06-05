import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/ai_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

/// A page that provides an interactive chat interface with the AI assistant.
///
/// This page provides:
/// - Real-time chat with the AI assistant
/// - Message history persistence
/// - Context-aware responses based on user data
/// - Chat management features (clear history)
/// - Visual feedback for AI responses
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

/// Manages the state of the AI chat page, including:
/// - Message history and persistence
/// - User input handling
/// - AI response generation
/// - Chat UI state management
class _AIPageState extends State<AIPage> {
  // Controllers for input and scrolling
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat state
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollToBottom();
  }

  /// Loads saved messages from local storage or initializes with welcome message
  void _loadMessages() {
    final box = Hive.box(Keys.chatBox);
    final savedMessages = box.get(
      'messages',
      defaultValue: <Map<String, dynamic>>[],
    );

    setState(() {
      _messages.clear();
      if (savedMessages.isEmpty) {
        // Add welcome message if no saved messages
        _addMessage(
          text:
              "Hello! I'm ${Keys.aiName}, your AI assistant. How can I help you today?",
          isUser: false,
          save: true,
        );
      } else {
        for (final msg in savedMessages) {
          _messages.add(
            ChatMessage(
              text: msg['text'] as String,
              isUser: msg['isUser'] as bool,
            ),
          );
        }
      }
    });
  }

  /// Saves current messages to local storage
  void _saveMessages() {
    final box = Hive.box(Keys.chatBox);
    final messagesToSave =
        _messages
            .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
            .toList();
    box.put('messages', messagesToSave);
  }

  /// Shows confirmation dialog and clears chat history
  void _clearChat() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat History'),
            content: const Text(
              'Are you sure you want to clear all messages? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _messages.clear());
                  _saveMessages();
                  Navigator.pop(context);
                  // Add welcome message back
                  _addMessage(
                    text:
                        "Hello! I'm ${Keys.aiName}, your AI assistant. How can I help you today?",
                    isUser: false,
                    save: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Adds a new message to the chat and optionally saves it
  void _addMessage({
    required String text,
    required bool isUser,
    bool save = true,
  }) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    if (save) {
      _saveMessages();
    }
    _scrollToBottom();
  }

  /// Scrolls the chat to the bottom with animation
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  /// Handles user message submission and generates AI response
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    _addMessage(text: text, isUser: true);

    // Add placeholder message and set typing state
    setState(() {
      _isTyping = true;
      _messages.add(ChatMessage(text: '', isUser: false)); // Placeholder for typing indicator
    });
    _scrollToBottom(); // Ensure the typing indicator is visible

    try {
      // Convert messages to format expected by AIService
      final chatHistory =
          _messages
              .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
              .toList();

      // Prepare context for AI including user data and tasks
      final taskBox = Hive.box<List>(Keys.taskBox);
      final chatContext = {
        'userName': FirebaseAuth.instance.currentUser?.displayName,
        'brainPoints': Hive.box(Keys.brainBox).get(Keys.brainPoints),
        'tasks':
            [
              ...(taskBox.get(Keys.actions) ?? []).map(
                (task) => task[Keys.title]?.toString() ?? '',
              ),
              ...(taskBox.get(Keys.flows) ?? []).map(
                (task) => task[Keys.title]?.toString() ?? '',
              ),
              ...(taskBox.get(Keys.moments) ?? []).map(
                (task) => task[Keys.title]?.toString() ?? '',
              ),
              ...(taskBox.get(Keys.thoughts) ?? []).map(
                (task) => task[Keys.title]?.toString() ?? '',
              ),
            ].where((text) => text.isNotEmpty).take(3).toList(),
      };

      // Get AI response and add to chat
      final reply = await AIService.askAI(
        text,
        chatHistory,
        chatContext: chatContext,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser && _messages.last.text == '') {
          _messages[_messages.length - 1] = ChatMessage(text: reply, isUser: false);
        } else {
          _messages.add(ChatMessage(text: reply, isUser: false));
        }
      });
    } catch (e) {
      _addMessage(
        text: "${Keys.aiName} had trouble replying. Please try again later.",
        isUser: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: Keys.aiName,
        actions: [
          // Clear Chat Button
          IconButton(
            icon: const Icon(ThemeIcons.clear),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
          // About Button
          IconButton(
            icon: const Icon(ThemeIcons.info),
            tooltip: 'About ${Keys.aiName}',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ThemeIcons.robot,
                              color: Colors.purple,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('About ${Keys.aiName}'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What can ${Keys.aiName} do?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Help organize your tasks and schedule\n'
                            '• Answer questions about productivity\n'
                            '• Provide suggestions for better focus\n'
                            '• Explain app features and functionality\n'
                            '• Offer personalized recommendations\n',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Coming Soon',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Voice interaction\n'
                            '• Task automation\n'
                            '• Advanced analytics\n',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: MyScrollShadow(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    message: message,
                    isTyping: _isTyping && index == _messages.length - 1,
                  );
                },
              ),
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                // Message Input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                IconButton(
                  onPressed: () => _handleSubmitted(_messageController.text),
                  icon: Icon(ThemeIcons.send, color: Colors.blue[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a chat message with:
/// - Message text content
/// - Sender identification (user or AI)
class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

/// A widget that displays a chat message bubble with:
/// - Different styling for user and AI messages
/// - Typing indicator for AI responses
/// - Consistent layout and spacing
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isTyping;

  const ChatBubble({super.key, required this.message, this.isTyping = false});

  @override
  Widget build(BuildContext context) {
    final showTypingIndicator = !message.isUser && message.text.isEmpty && isTyping;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.purple[100],
                shape: BoxShape.circle,
              ),
              child: Icon(ThemeIcons.robot, color: Colors.purple, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          // Message Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: showTypingIndicator
                  ? const TypingIndicator()
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.blue[900] : Colors.black87,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Icon(ThemeIcons.user, color: Colors.blue[700], size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

/// A widget that displays an animated typing indicator
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  /// Builds a dot for the typing indicator
  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: (sin((value + index * 0.4) * 2 * 3.14159) + 1) / 2,
            child: child,
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
