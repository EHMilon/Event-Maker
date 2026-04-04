import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_maker/models/booking_notification_model.dart';
import 'package:event_maker/services/booking_notification_repository.dart';
import 'package:event_maker/services/api_exception.dart';

class NotificationController extends GetxController {
  final BookingNotificationRepository _repository =
      BookingNotificationRepository();

  // Loading states
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data - using real booking notifications from API
  final RxList<BookingNotificationModel> bookingNotifications =
      <BookingNotificationModel>[].obs;

  // Legacy support for existing UI
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<ServiceRequest> serviceRequests = <ServiceRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Fetch booking notifications from API
  Future<void> fetchNotifications() async {
    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      hasError.value = true;
      errorMessage.value = 'noInternet'.tr;
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _repository.fetchBookingNotifications();

      if (response.success) {
        bookingNotifications.assignAll(response.data);
        // Also populate legacy serviceRequests for backward compatibility
        _convertToServiceRequests(response.data);
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
      }
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      Log.e('Notification fetch error: ${e.message}');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'serverError'.tr;
      Log.e('Notification fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert booking notifications to legacy ServiceRequest format
  void _convertToServiceRequests(List<BookingNotificationModel> notifications) {
    serviceRequests.clear();
    for (final notification in notifications) {
      serviceRequests.add(
        ServiceRequest(
          id: notification.id.toString(),
          customerName: notification.customer.fullName,
          customerImage: notification.customer.avatar ?? '',
          serviceTitle: notification.title,
          serviceDescription: '',
          date: DateTime.now(),
          location: '',
          price: 0,
          priceUnit: 'AED',
          status: RequestStatus.pending,
          createdAt: notification.createdAt,
        ),
      );
    }
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
        type: notifications[index].type,
      );
    }
  }

  void clearAllNotifications() {
    notifications.clear();
  }

  void acceptRequest(String requestId) {
    final index = serviceRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      serviceRequests[index] = ServiceRequest(
        id: serviceRequests[index].id,
        customerName: serviceRequests[index].customerName,
        customerImage: serviceRequests[index].customerImage,
        serviceTitle: serviceRequests[index].serviceTitle,
        serviceDescription: serviceRequests[index].serviceDescription,
        date: serviceRequests[index].date,
        location: serviceRequests[index].location,
        price: serviceRequests[index].price,
        priceUnit: serviceRequests[index].priceUnit,
        status: RequestStatus.accepted,
      );
    }
  }

  void rejectRequest(String requestId) {
    final index = serviceRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      serviceRequests[index] = ServiceRequest(
        id: serviceRequests[index].id,
        customerName: serviceRequests[index].customerName,
        customerImage: serviceRequests[index].customerImage,
        serviceTitle: serviceRequests[index].serviceTitle,
        serviceDescription: serviceRequests[index].serviceDescription,
        date: serviceRequests[index].date,
        location: serviceRequests[index].location,
        price: serviceRequests[index].price,
        priceUnit: serviceRequests[index].priceUnit,
        status: RequestStatus.rejected,
      );
    }
  }

  ServiceRequest? getRequestById(String requestId) {
    try {
      return serviceRequests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });
}

class ServiceRequest {
  final String id;
  final String customerName;
  final String customerImage;
  final String serviceTitle;
  final String serviceDescription;
  final DateTime date;
  final String location;
  final double price;
  final String priceUnit;
  final RequestStatus status;
  final String createdAt;

  ServiceRequest({
    required this.id,
    required this.customerName,
    required this.customerImage,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.date,
    required this.location,
    required this.price,
    required this.priceUnit,
    required this.status,
    this.createdAt = '',
  });
}

enum RequestStatus { pending, accepted, rejected }

enum NotificationType { booking, payment, review, reminder }

/// Simple logger for this controller
class Log {
  static void d(String message) {
    print('[NotificationController] $message');
  }

  static void e(String message) {
    print('[NotificationController ERROR] $message');
  }
}
