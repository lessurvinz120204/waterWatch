import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Format date as "MMM d, yyyy"
  String toFormattedDate() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format time as "HH:mm"
  String toFormattedTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as "MMM d, yyyy - HH:mm"
  String toFormattedDateTime() {
    return DateFormat('MMM d, yyyy - HH:mm').format(this);
  }

  /// Check if announcement is currently active
  bool isActive(DateTime startTime, DateTime endTime) {
    return isAfter(startTime) && isBefore(endTime);
  }

  /// Get relative time string (e.g., "2 hours ago")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return toFormattedDate();
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }
}

extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Check if string is email
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int length) {
    if (this.length <= length) return this;
    return substring(0, length) + '...';
  }
}
