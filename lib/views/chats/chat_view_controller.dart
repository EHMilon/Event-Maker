import 'package:get/get.dart';

class ChatViewController extends GetxController {
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  // Dummy data
  final RxList<Map<String, dynamic>> customerChats =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> adminChats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() async {
    isLoading.value = true;
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Add 2s delay with shimmer
    customerChats.value = [
      {
        'id': '1',
        'name': 'Jony Gomes',
        'lastMessage': 'Hi! How are you? 😊',
        'image': 'assets/images/person.jpg',
        'time': '9:41 AM',
        'unread': 0,
      },
    ];

    // TODO: Replace mock admin chat with real admin thread list from API
    adminChats.value = [
      {
        'id': 'admin-1',
        'name': 'EventMaker Admin',
        'lastMessage': 'Hello, how can we assist you today?',
        'image': 'assets/images/person.jpg',
        'time': '10:15 AM',
        'unread': 1,
      },
    ];

    isLoading.value = false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
