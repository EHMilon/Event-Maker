import 'package:get/get.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<ServiceRequest> serviceRequests = <ServiceRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadServiceRequests();
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
        type: NotificationType.booking,
      ),
      NotificationModel(
        id: '2',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: false,
        type: NotificationType.booking,
      ),
      NotificationModel(
        id: '3',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      NotificationModel(
        id: '4',
        title: 'Clara Tolson',
        body: 'Accepted your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      NotificationModel(
        id: '5',
        title: 'Clara Tolson',
        body: 'Rejected your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
      ),
      NotificationModel(
        id: '6',
        title: 'Clara Tolson',
        body: 'Rejected your booking request',
        timeAgo: '9 hr ago',
        isRead: true,
        type: NotificationType.booking,
      ),
    ]);
  }

  void _loadServiceRequests() {
    serviceRequests.addAll([
      ServiceRequest(
        id: 'req-1',
        customerName: 'Clara Tolson',
        customerImage:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop',
        serviceTitle: 'Wedding Photography',
        serviceDescription:
            'Full day wedding photography coverage with 500+ edited photos',
        date: DateTime.now().add(const Duration(days: 2)),
        location: 'Grand Hyatt, Dubai',
        price: 2500,
        priceUnit: 'AED',
        status: RequestStatus.pending,
      ),
      ServiceRequest(
        id: 'req-2',
        customerName: 'John Smith',
        customerImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
        serviceTitle: 'Catering Service',
        serviceDescription: 'Buffet style catering for 100 guests',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Marina Mall, Abu Dhabi',
        price: 3500,
        priceUnit: 'AED',
        status: RequestStatus.pending,
      ),
      ServiceRequest(
        id: 'req-3',
        customerName: 'Emily Johnson',
        customerImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=100&auto=format&fit=crop',
        serviceTitle: 'Live Music Band',
        serviceDescription: 'Jazz band performance for 4 hours',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Emirates Palace',
        price: 2000,
        priceUnit: 'AED',
        status: RequestStatus.pending,
      ),
      ServiceRequest(
        id: 'req-4',
        customerName: 'Michael Brown',
        customerImage:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100&auto=format&fit=crop',
        serviceTitle: 'Video Production',
        serviceDescription: 'Cinematic wedding video with highlight reel',
        date: DateTime.now().add(const Duration(days: 10)),
        location: 'Burj Al Arab',
        price: 4500,
        priceUnit: 'AED',
        status: RequestStatus.pending,
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
  });
}

enum RequestStatus { pending, accepted, rejected }
enum NotificationType { booking, payment, review, reminder }
