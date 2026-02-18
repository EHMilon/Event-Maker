import 'package:get/get.dart';
import '../../../data/mock/mock_data.dart';
import '../../../core/routes/app_routes.dart';

class CustomerNotificationController extends GetxController {
  final RxList<CustomerNotificationModel> notifications =
      <CustomerNotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
    // Simulate 2s delay for shimmer effect as per user rules
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with actual API call
    notifications.addAll([
      CustomerNotificationModel(
        id: '1',
        title: 'photography',
        body: 'acceptedBookingBody',
        timeAgo: '2 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'photo-1',
      ),
      CustomerNotificationModel(
        id: '2',
        title: 'catering',
        body: 'acceptedBookingBody',
        timeAgo: '4 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'cat-1',
      ),
      CustomerNotificationModel(
        id: '3',
        title: 'music',
        body: 'rejectedBookingBody',
        timeAgo: '1 day ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      CustomerNotificationModel(
        id: '4',
        title: 'event',
        body: 'confirmedBookingBody',
        timeAgo: '2 days ago',
        isRead: true,
        type: NotificationType.reminder,
      ),
      CustomerNotificationModel(
        id: '5',
        title: 'payment',
        body: 'paymentReceivedBody',
        timeAgo: '3 days ago',
        isRead: true,
        type: NotificationType.payment,
      ),
      CustomerNotificationModel(
        id: '6',
        title: 'photography',
        body: 'newServiceAvailableBody',
        timeAgo: '1 week ago',
        isRead: true,
        type: NotificationType.promotion,
      ),
    ]);
    isLoading.value = false;
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
        serviceId: notifications[index].serviceId,
      );
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }

  void handleNotificationClick(CustomerNotificationModel notification) {
    markAsRead(notification.id);

    if (notification.serviceId != null &&
        (notification.body == 'acceptedBookingBody' ||
            notification.body.tr.contains('accepted'.tr))) {
      // Find service in HomeController or MockData
      final service = MockData.homeServices.firstWhereOrNull(
        (s) => s.id == notification.serviceId,
      );

      if (service != null) {
        Get.toNamed(
          AppRoutes.payment,
          arguments: {'service': service, 'package': service.packages?.first},
        );
      }
    }
  }
}

class CustomerNotificationModel {
  final String id;
  final String title;
  final String body; // This will hold the localization key or the actual text
  final String timeAgo;
  final bool isRead;
  final NotificationType type;
  final String? serviceId;

  CustomerNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
    this.serviceId,
  });
}

enum NotificationType { booking, reminder, payment, promotion }
