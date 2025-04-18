import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Help & Definitions',
        leading: IconButton(
          icon: const Icon(ThemeIcons.backIcon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            title: 'Focus Categories',
            children: [
              _buildCategoryCard(
                icon: ThemeIcons.actionsIcon,
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
                icon: ThemeIcons.flowsIcon,
                title: 'Flows',
                description:
                    'Recurring routines or processes that you want to maintain. These are your habits and regular activities.',
                color: ThemeColours.flowsMain,
                examples: [
                  'Morning workout routine',
                  'Weekly team meeting',
                  'Monthly budget review',
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                icon: ThemeIcons.momentsIcon,
                title: 'Moments',
                description:
                    'Time-specific events or appointments. These are your scheduled activities with a specific date and time.',
                color: ThemeColours.momentsMain,
                examples: [
                  'Doctor\'s appointment',
                  'Team presentation',
                  'Birthday party',
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                icon: ThemeIcons.thoughtsIcon,
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
          _buildSection(
            title: 'Tags & Organization',
            children: [
              _buildInfoCard(
                title: 'Using Tags',
                content:
                    'Tags help you organize items within each category. You can:\n\n'
                    '• Add multiple tags to any item\n'
                    '• Filter items by tags\n'
                    '• Create custom tags for your needs\n'
                    '• Use tags to group similar items',
                icon: Icons.filter_list,
                color: ThemeColours.taskMain,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Default Tags',
                content:
                    'Each category comes with default tags:\n\n'
                    '• Actions: Home, Work, Errands\n'
                    '• Flows: Morning, Evening, Wellness\n'
                    '• Moments: Appointments, Social, Work\n'
                    '• Thoughts: Ideas, Journal, Tasks',
                icon: ThemeIcons.tagIcon,
                color: ThemeColours.actionsMain,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Brain Points',
                content:
                    'Completing items uses Brain Points:\n\n'
                    '• Actions: Points based on mental effort\n'
                    '• Flows: Points based on maintaining streaks\n',
                icon: Icons.psychology,
                color: ThemeColours.thoughtsMain,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
