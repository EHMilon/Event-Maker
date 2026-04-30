import 'package:get/get.dart';
import '../../app_routes.dart';
import '../../services/customer_booking_repository.dart';
import '../../services/api_exception.dart';
import '../../constants/api_constant.dart';
import '../../global/base_controller.dart';

class CustomerNotificationController extends BaseController {
  final RxList<CustomerNotificationModel> notifications =
      <CustomerNotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final CustomerBookingRepository _repository = CustomerBookingRepository();

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  /// Refresh notifications when screen is resumed
  void onResume() {
    refreshNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch from API: GET /bookings/notification-list
      final response = await _repository.fetchNotifications();

      // Minimum shimmer display delay
      await Future.delayed(const Duration(milliseconds: 350));

      // Map API response to local model
      notifications.assignAll(
        response.data.map((apiNotification) {
          // Determine notification body based on accepted/rejected status
          final bool isAccepted = apiNotification.acceptedAt != null;
          final bool isRejected = apiNotification.rejectedAt != null;

          return CustomerNotificationModel(
            id: apiNotification.id.toString(),
            title: apiNotification.provider.fullName,
            body: isAccepted
                ? 'acceptedBookingBody'
                : (isRejected ? 'rejectedBookingBody' : 'pendingBookingBody'),
            timeAgo:
                apiNotification.acceptedAt ?? apiNotification.rejectedAt ?? '',
            isRead: isAccepted || isRejected,
            type: NotificationType.booking,
            serviceId: apiNotification.serviceId.toString(),
            providerId: apiNotification.providerId,
            bookingId: apiNotification.id,
            // Get full URL for provider avatar from API
            coverImage: ApiConstant.getFullMediaUrl(
              apiNotification.provider.avatar,
            ),
            // Include booking date and time from API response
            bookingDate: apiNotification.bookingDate,
            bookingTime: apiNotification.startTime,
          );
        }).toList(),
      );

      isLoading.value = false;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to load notifications';
      isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadNotifications();
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
        providerId: notifications[index].providerId,
        bookingId: notifications[index].bookingId,
        coverImage: notifications[index].coverImage,
        bookingDate: notifications[index].bookingDate,
        bookingTime: notifications[index].bookingTime,
      );
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }

  void handleNotificationClick(CustomerNotificationModel notification) {
    markAsRead(notification.id);
    // Handle accepted bookings - navigate to payment with booking details
    if (notification.body == 'acceptedBookingBody' &&
        notification.bookingId != null) {
      // Navigate to payment screen with the booking ID and date/time info
      // The payment screen will fetch the booking details using the ID
      Get.toNamed(
        AppRoutes.payment,
        arguments: {
          'booking_id': notification.bookingId,
          'booking_date': notification.bookingDate ?? '',
          'booking_time': notification.bookingTime ?? '',
        },
      );
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
  final int? providerId;
  final int? bookingId;
  final String? coverImage;
  final String? bookingDate;
  final String? bookingTime;

  CustomerNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
    this.serviceId,
    this.providerId,
    this.bookingId,
    this.coverImage,
    this.bookingDate,
    this.bookingTime,
  });
}

enum NotificationType { booking, reminder, payment, promotion }
