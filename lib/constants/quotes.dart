import 'dart:math';

/// Represents a motivational quote with its text, author, and category.
/// Used to display inspirational messages throughout the app.
class Quote {
  /// The actual quote text
  final String text;

  /// The person who said/wrote the quote
  final String author;

  /// The category or theme of the quote (e.g., Focus, Motivation, etc.)
  final String category;

  /// Creates a new Quote instance.
  ///
  /// [text] - The actual quote text
  /// [author] - The person who said/wrote the quote
  /// [category] - The category or theme of the quote
  const Quote({
    required this.text,
    required this.author,
    required this.category,
  });
}

/// Manages a collection of motivational quotes and provides methods to access them.
/// This class maintains a predefined list of quotes and offers functionality
/// to retrieve random quotes for display in the app.
class Quotes {
  /// Internal list of predefined quotes used throughout the app
  static final List<Quote> _quotes = [
    Quote(
      text:
          "Discipline is choosing between what you want now and what you want most.",
      author: "Abraham Lincoln",
      category: "Focus",
    ),
    Quote(
      text: "Small progress is still progress.",
      author: "Unknown",
      category: "Motivation",
    ),
    Quote(
      text: "Do one thing at a time, and do it well.",
      author: "Steve Jobs",
      category: "Productivity",
    ),
    Quote(
      text: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
      category: "Motivation",
    ),
    Quote(
      text: "Your time is limited, don't waste it living someone else's life.",
      author: "Steve Jobs",
      category: "Life",
    ),
    Quote(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: "Work",
    ),
    Quote(
      text:
          "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
      category: "Motivation",
    ),
    Quote(
      text:
          "The future belongs to those who believe in the beauty of their dreams.",
      author: "Eleanor Roosevelt",
      category: "Inspiration",
    ),
    Quote(
      text: "Don't watch the clock; do what it does. Keep going.",
      author: "Sam Levenson",
      category: "Persistence",
    ),
    Quote(
      text:
          "The only limit to our realization of tomorrow is our doubts of today.",
      author: "Franklin D. Roosevelt",
      category: "Growth",
    ),
  ];

  /// Returns a random quote from the predefined collection.
  ///
  /// This method uses Dart's Random class to select a quote at random
  /// from the internal [_quotes] list.
  static Quote getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }
}
