import 'package:flutter/material.dart';

class NotificationUtils {
  static IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'entretien':
        return Icons.build_outlined;
      case 'alerte':
        return Icons.warning_outlined;
      case 'rappel':
        return Icons.calendar_today_outlined;
      case 'suivi':
        return Icons.history_outlined;
      default:
        return Icons.notifications; // fallback
    }
  }

  static Color getIconBackgroundColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'entretien':
        return Theme.of(context).primaryColor.withOpacity(0.1);
      case 'alerte':
        return Colors.red[100]!;
      case 'rappel':
        return Colors.orange[100]!;
      case 'suivi':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  static Color getIconColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'entretien':
        return Theme.of(context).primaryColor;
      case 'alerte':
        return Colors.red;
      case 'rappel':
        return Colors.orange;
      case 'suivi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
