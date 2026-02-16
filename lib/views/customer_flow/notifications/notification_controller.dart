import 'package:get/get.dart';

class CustomerNotificationController extends GetxController {
  final RxList<CustomerNotificationModel> notifications = <CustomerNotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    // TODO: Replace with actual API call
    notifications.addAll([
      CustomerNotificationModel(
        id: '1',
        title: 'Photography Service',
        body: 'Your booking request has been accepted',
        timeAgo: '2 hr ago',
        isRead: false,
        type: NotificationType.booking,
      ),
      CustomerNotificationModel(
        id: '2',
        title: 'Catering Service',
        body: 'Your booking request has been accepted',
        timeAgo: '4 hr ago',
        isRead: false,
        type: NotificationType.booking,
      ),
      CustomerNotificationModel(
        id: '3',
        title: 'Music Band',
        body: 'Your booking request has been rejected',
        timeAgo: '1 day ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      CustomerNotificationModel(
        id: '4',
        title: 'Venue Booking',
        body: 'Your booking is confirmed for tomorrow',
        timeAgo: '2 days ago',
        isRead: true,
        type: NotificationType.reminder,
      ),
      CustomerNotificationModel(
        id: '5',
        title: 'Payment Received',
        body: 'We have received your payment',
        timeAgo: '3 days ago',
        isRead: true,
        type: NotificationType.payment,
      ),
      CustomerNotificationModel(
        id: '6',
        title: 'New Service Available',
        body: 'Photography services are now available in your area',
        timeAgo: '1 week ago',
        isRead: true,
        type: NotificationType.promotion,
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = CustomerNotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        timeAgo: notifications[index].timeAgo,
        isRead: true,
        type: notifications[index].type,
      );
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }
}

class CustomerNotificationModel {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final NotificationType type;

  CustomerNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });
}

enum NotificationType { booking, reminder, payment, promotion }