import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stage/features/notifications/models/notification_type.dart';
import 'package:stage/features/notifications/repositories/notification_repository.dart';
import 'package:stage/features/notifications/utils/notification_utils.dart';
import 'package:stage/utils/app_textstyles.dart';
class NotificationsScreen extends StatelessWidget {
  final NotificationRepository _repository = NotificationRepository();
  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = _repository.getNotifications();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                "Marquer tout comme lu",
                style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    Theme.of(context).primaryColor,
                ),
              ),
          )
        ],

      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) => _buildNotificationCard(
            context,
            notifications[index],
          ),
      ),
    );
  }
  Widget _buildNotificationCard(BuildContext context, NotificationItem notification){
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isRead?
            Theme.of(context).cardColor
            : Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NotificationUtils.getIconBackgroundColor(context, notification.type),
            shape: BoxShape.circle,
          ),
          child: Icon(
            NotificationUtils.getNotificationIcon(notification.type),
            color: NotificationUtils.getIconColor(context, notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: AppTextStyle.withColor(
              AppTextStyle.bodyLarge,
              Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start ,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            )
          ],
        ),
      ),
    );
  }
}
