import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/ai_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollToBottom();
  }

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

  void _saveMessages() {
    final box = Hive.box(Keys.chatBox);
    final messagesToSave =
        _messages
            .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
            .toList();
    box.put('messages', messagesToSave);
  }

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

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    _addMessage(text: text, isUser: true);

    setState(() => _isTyping = true);

    try {
      // Convert messages to format expected by AIService
      final chatHistory =
          _messages
              .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
              .toList();

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

      final reply = await AIService.askAI(
        text,
        chatHistory,
        chatContext: chatContext,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      _addMessage(text: reply, isUser: false);
    } catch (e) {
      _addMessage(
        text: "${Keys.aiName} had trouble replying. Please try again later.",
        isUser: false,
      );
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: Keys.aiName,
        actions: [
          IconButton(
            icon: const Icon(ThemeIcons.clear),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
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
                            '• Task creation and management\n'
                            '• Calendar integration\n'
                            '• Advanced AI capabilities',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[50]),
                child: MyScrollShadow(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontFamily: null,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({bool isUser = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[100] : Colors.purple[100],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? ThemeIcons.user : ThemeIcons.robot,
          color: isUser ? Colors.blue : Colors.purple,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(children: [_buildDot(0), _buildDot(1), _buildDot(2)]),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(179),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _handleSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(ThemeIcons.send, color: Colors.white),
              onPressed: () => _handleSubmitted(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
