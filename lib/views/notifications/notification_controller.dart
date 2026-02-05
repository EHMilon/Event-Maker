import 'package:event_maker/views/notifications/notification_view.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    // TODO: Replace with actual API call
    notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Clara Tolson',
        body: ' Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Clara Tolson',
        body: 'Rejected your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Clara Tolson',
        body: 'Rejected your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        timeAgo: notifications[index].timeAgo,
        isRead: true,
      );
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }
}
