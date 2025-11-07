import 'package:intl/intl.dart';

extension RelativeTimeFormatting on String {
  String toRelativeTime() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(parsedDate);

      // Handle future dates
      if (difference.isNegative) {
        return DateFormat('dd MMM, yyyy').format(parsedDate);
      }

      // Less than a minute
      if (difference.inMinutes < 1) {
        return 'Just now';
      }

      // Less than an hour
      if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
      }

      // Less than a day (24 hours)
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
      }

      // Less than a week (7 days)
      if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      }

      // Otherwise, return the full date
      return DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }

  String toWhatsAppRelativeTime() {
    try {
      final DateTime parsedDate = DateTime.parse(this);
      final DateTime now = DateTime.now();

      // Create date-only objects for comparison (ignoring time)
      final DateTime parsedDateOnly = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));

      // Handle today
      if (parsedDateOnly == today) {
        return 'Today';
      }

      // Handle yesterday
      if (parsedDateOnly == yesterday) {
        return 'Yesterday';
      }

      // Handle current year dates - show "22 October"
      if (parsedDate.year == now.year) {
        return DateFormat('dd MMMM').format(parsedDate);
      }

      // Handle previous years - show "22 December 2024"
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}
