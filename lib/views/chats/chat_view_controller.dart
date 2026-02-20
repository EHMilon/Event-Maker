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
    adminChats.value = []; // empty state
    isLoading.value = false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
