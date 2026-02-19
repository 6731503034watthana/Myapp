import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }
}
