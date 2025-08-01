import 'package:flutter/material.dart';
import 'package:stage/features/notifications/models/notification_type.dart';

class NotificationUtils {
  static IconData getNotificationIcon(NotificationType type){
    switch(type){
      case NotificationType.entretien:
        return Icons.build_outlined;
      case NotificationType.alerte:
        return Icons.warning_outlined;
      case NotificationType.rappel:
        return Icons.calendar_today_outlined;
      case NotificationType.suivi:
        return Icons.history_outlined;
    }
  }

  static Color getIconBackgroundColor(BuildContext context, NotificationType type){
    switch(type){
      case NotificationType.entretien:
        return Theme.of(context).primaryColor.withOpacity(0.1);
      case NotificationType.alerte:
        return Colors.red[100]!;
      case NotificationType.rappel:
        return Colors.orange[100]!;
      case NotificationType.suivi:
        return Colors.green[100]!;
    }
  }

  static Color getIconColor (BuildContext context, NotificationType type){
    switch(type){
      case NotificationType.entretien:
        return Theme.of(context).primaryColor.withOpacity(0.1);
      case NotificationType.alerte:
        return Colors.red;
      case NotificationType.rappel:
        return Colors.orange;
      case NotificationType.suivi:
        return Colors.green;
    }
  }
}