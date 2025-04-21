import 'package:flutter_test/flutter_test.dart';
import 'package:focusyn_app/models/task_model.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation with required fields', () {
      final task = Task(title: 'Test Task');

      expect(task.title, equals('Test Task'));
      expect(task.list, equals('All')); // Default value
      expect(task.id, isNotNull);
      expect(task.createdAt, isNotNull);
    });

    test('copyWith updates correct fields', () {
      final task = Task(title: 'Original Task', priority: 1);

      final updatedTask = task.copyWith(title: 'Updated Task', priority: 2);

      expect(updatedTask.title, equals('Updated Task'));
      expect(updatedTask.priority, equals(2));
      expect(updatedTask.id, equals(task.id)); // Should keep the same ID
    });

    test('getPriorityText returns correct priority text', () {
      expect(Task.getPriorityText(1), equals('Urgent, Important'));
      expect(Task.getPriorityText(2), equals('Not Urgent, Important'));
      expect(Task.getPriorityText(3), equals('Urgent, Not Important'));
      expect(Task.getPriorityText(4), equals('Not Urgent, Not Important'));
      expect(Task.getPriorityText(0), equals('Unknown Priority'));
    });

    test('isOverdue correctly identifies overdue tasks', () {
      final pastDate = DateTime.now().subtract(Duration(days: 1));
      final futureDate = DateTime.now().add(Duration(days: 1));

      final overdueTask = Task(
        title: 'Overdue Task',
        date: pastDate.toIso8601String().split('T')[0],
        time: '09:00',
      );

      final upcomingTask = Task(
        title: 'Future Task',
        date: futureDate.toIso8601String().split('T')[0],
        time: '09:00',
      );

      final noDateTask = Task(title: 'No Date Task');

      expect(Task.isOverdue(overdueTask.date!, overdueTask.time), isTrue);
      expect(Task.isOverdue(upcomingTask.date!, upcomingTask.time), isFalse);
      expect(Task.isOverdue(noDateTask.date ?? '', noDateTask.time), isFalse);
    });

    test('formatDate returns appropriate date format', () {
      final today = DateTime.now();
      final nextWeek = today.add(Duration(days: 7));
      final nextYear = DateTime(today.year + 1, today.month, today.day);

      final todayTask = Task(
        title: 'Today Task',
        date: today.toIso8601String().split('T')[0],
      );

      final nextWeekTask = Task(
        title: 'Next Week Task',
        date: nextWeek.toIso8601String().split('T')[0],
      );

      final nextYearTask = Task(
        title: 'Next Year Task',
        date: nextYear.toIso8601String().split('T')[0],
      );

      expect(Task.formatDate(todayTask.date!), isNotEmpty);
      expect(Task.formatDate(nextWeekTask.date!), isNotEmpty);
      expect(Task.formatDate(nextYearTask.date!), isNotEmpty);
    });
  });
}
