import 'package:get/get.dart';
import '../../mock_data/mock_data.dart';
import '../../app_routes.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    notifications.addAll([
      CustomerNotificationModel(
        id: '1',
        title: 'Clara Tolson',
        body: 'acceptedBookingBody',
        timeAgo: '9 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'cat-1',
      ),
      CustomerNotificationModel(
        id: '2',
        title: 'Clara Tolson',
        body: 'acceptedBookingBody',
        timeAgo: '9 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'cat-2',
      ),
      CustomerNotificationModel(
        id: '3',
        title: 'Clara Tolson',
        body: 'acceptedBookingBody',
        timeAgo: '9 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'photo-1',
      ),
      CustomerNotificationModel(
        id: '4',
        title: 'Clara Tolson',
        body: 'acceptedBookingBody',
        timeAgo: '9 hr ago',
        isRead: false,
        type: NotificationType.booking,
        serviceId: 'film-1',
      ),
      CustomerNotificationModel(
        id: '5',
        title: 'Clara Tolson',
        body: 'rejectedBookingBody',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      CustomerNotificationModel(
        id: '6',
        title: 'Clara Tolson',
        body: 'rejectedBookingBody',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
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
        notification.body == 'acceptedBookingBody') {
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
  final String body;
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
