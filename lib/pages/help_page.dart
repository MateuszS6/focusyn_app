import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';

/// A page that provides help and documentation for the application.
///
/// This page includes:
/// - Detailed explanations of focus categories
/// - Task interaction guidelines
/// - List management instructions
/// - Rich text formatting support
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  /// Converts text with simple markup to a RichText widget.
  ///
  /// Supports the following formatting:
  /// - *text* for bold text
  /// - /text/ for italic text
  ///
  /// [content] is the text to format
  /// [fontSize] is the base font size (defaults to 16)
  Widget _buildRichText(String content, {double fontSize = 16}) {
    final List<TextSpan> spans = []; // List of text spans to display
    final RegExp boldPattern = RegExp(r'\*(.*?)\*'); // Bold text
    final RegExp italicPattern = RegExp(r'\/(.*?)\/'); // Italic text

    // Remaining text to process
    String remainingText = content;

    while (remainingText.isNotEmpty) {
      Match? boldMatch = boldPattern.firstMatch(remainingText);
      Match? italicMatch = italicPattern.firstMatch(remainingText);

      // No more formatting found, add remaining text and break
      if (boldMatch == null && italicMatch == null) {
        spans.add(TextSpan(text: remainingText));
        break;
      }

      // Determine which pattern comes first
      bool boldFirst =
          boldMatch != null &&
          (italicMatch == null || boldMatch.start < italicMatch.start);
      Match match = boldFirst ? boldMatch : italicMatch!;

      // Add text before the match
      if (match.start > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, match.start)));
      }

      // Add the formatted text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: boldFirst ? FontWeight.bold : FontWeight.normal,
            fontStyle: boldFirst ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      );

      // Update remaining text
      remainingText = remainingText.substring(match.end);
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: Colors.black87),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Help & Definitions',
        leading: IconButton(
          icon: const Icon(ThemeIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Focus Categories section
          _buildSection(
            title: 'Focus Categories',
            children: [
              _buildCategoryCard(
                icon: ThemeIcons.actions,
                title: 'Actions',
                description:
                    'One-time tasks or to-dos that need to be completed. These are your immediate tasks that have a clear endpoint.',
                color: ThemeColours.actionsMain,
                examples: [
                  'Complete project report',
                  'Buy groceries',
                  'Call dentist',
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                icon: ThemeIcons.flows,
                title: 'Flows',
                description:
                    'Recurring routines or processes that you want to maintain. These are your habits and regular activities.',
                color: ThemeColours.flowsMain,
                examples: [
                  'Morning workout',
                  'Weekly team meeting',
                  'Monthly budget review',
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                icon: ThemeIcons.moments,
                title: 'Moments',
                description:
                    'Time-specific events or appointments. These are your scheduled activities with a specific date, time.',
                color: ThemeColours.momentsMain,
                examples: [
                  'Doctor\'s appointment',
                  'Team presentation',
                  'Birthday party',
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                icon: ThemeIcons.thoughts,
                title: 'Thoughts',
                description:
                    'Ideas, notes, or reflections you want to remember. These are your mental notes and creative thoughts.',
                color: ThemeColours.thoughtsMain,
                examples: [
                  'Book recommendations',
                  'Project ideas',
                  'Personal reflections',
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Task Interactions section
          _buildSection(
            title: 'Task Interactions',
            children: [
              _buildInfoCard(
                title: 'Brain Points',
                content:
                    'Completing items uses /Brain Points/:\n\n'
                    '• Actions: Points based on mental effort\n'
                    '• Flows: Points based on maintaining streaks\n',
                icon: Icons.psychology,
                color: ThemeColours.thoughtsMain,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Managing Tasks',
                content:
                    'You can quickly manage your tasks with gestures:\n\n'
                    '• *Tap* the /checkmark/ to mark as complete\n'
                    '• *Hold* any task to edit its details\n'
                    '• *Swipe left* on a task to delete it\n\n'
                    'These gestures work the same way across all /Focus Categories/.',
                icon: ThemeIcons.tasks,
                color: ThemeColours.taskMain,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Lists & Organization section
          _buildSection(
            title: 'Lists & Organization',
            children: [
              _buildInfoCard(
                title: 'Using Lists',
                content:
                    'Lists help you organize items within each category. You can:\n\n'
                    '• Create /custom lists/ for your needs\n'
                    '• Use lists to /group similar items/\n\n'
                    '*Double tap* the list name to edit it.\n'
                    '*Long press* the list name to delete it.',
                icon: Icons.filter_list,
                color: ThemeColours.taskMain,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Default Lists',
                content:
                    'Each category comes with default lists:\n\n'
                    '• Actions: Home, Work, Errands\n'
                    '• Flows: Morning, Evening, Wellness\n'
                    '• Moments: Appointments, Social, Work\n'
                    '• Thoughts: Ideas, Journal, Tasks',
                icon: ThemeIcons.tag,
                color: ThemeColours.actionsMain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a section with a title and its content.
  ///
  /// [title] is the section header
  /// [children] are the widgets to display in the section
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  /// Builds a card displaying information about a focus category.
  ///
  /// [icon] is the category's icon
  /// [title] is the category name
  /// [description] explains the category's purpose
  /// [color] is the category's theme color
  /// [examples] are sample tasks for the category
  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          const Text(
            'Examples:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          ...examples.map(
            (example) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(example, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a card displaying general information.
  ///
  /// [title] is the information title
  /// [content] is the formatted text content
  /// [icon] is the information icon
  /// [color] is the card's theme color
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRichText(content),
        ],
      ),
    );
  }
}
