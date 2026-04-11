import 'package:get/get.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/views/chats/chat_repository.dart';

/// Controller for the chat list view.
/// Uses [ChatRepository] for all chat operations with backend API.
class ChatViewController extends GetxController {
  final ChatRepository _repository = ChatRepository();

  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final hasError = false.obs;
  String? errorMessage;

  // Chat lists using proper models
  final RxList<ChatModel> customerChats = <ChatModel>[].obs;
  final RxList<ChatModel> adminChats = <ChatModel>[].obs;

  // Filtered lists for search
  final RxList<ChatModel> filteredCustomerChats = <ChatModel>[].obs;
  final RxList<ChatModel> filteredAdminChats = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();

    // Listen to search query changes and filter chats
    ever(searchQuery, (_) => _filterChats());
  }

  /// Loads both customer chats and admin chats from API.
  Future<void> loadChats() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = null;

    try {
      // Fetch customer chats from real API (chat_type=normal)
      final normalChats = await _repository.fetchNormalChats();
      customerChats.value = normalChats;
      filteredCustomerChats.value = normalChats;

      // Fetch admin chats from real API (chat_type=admin)
      final fetchedAdminChats = await _repository.fetchAdminChats();
      adminChats.value = fetchedAdminChats;
      filteredAdminChats.value = fetchedAdminChats;
    } catch (e) {
      hasError.value = true;
      errorMessage = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes the chat lists (for pull-to-refresh and when returning from chat).
  Future<void> refreshChats() async {
    // Set loading to true to show shimmer, then load new data
    isLoading.value = true;
    await loadChats();
  }

  /// Updates the search query and triggers filtering.
  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();
  }

  /// Filters chats based on the current search query.
  void _filterChats() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      filteredCustomerChats.value = customerChats.toList();
      filteredAdminChats.value = adminChats.toList();
      return;
    }

    filteredCustomerChats.value = customerChats.where((chat) {
      final otherMember = chat.members.isNotEmpty ? chat.members.first : null;
      final name = otherMember?.fullName ?? otherMember?.email ?? '';
      final lastMsg = chat.lastMessage?.content ?? '';
      return name.toLowerCase().contains(query) ||
          lastMsg.toLowerCase().contains(query);
    }).toList();

    filteredAdminChats.value = adminChats.where((chat) {
      final adminMember = chat.members.firstWhereOrNull(
        (m) => m.role == 'admin',
      );
      final name =
          adminMember?.fullName ?? adminMember?.email ?? chat.name ?? '';
      final lastMsg = chat.lastMessage?.content ?? '';
      return name.toLowerCase().contains(query) ||
          lastMsg.toLowerCase().contains(query);
    }).toList();
  }

  /// Gets a specific chat by ID.
  ChatModel? getChatById(String chatId) {
    try {
      return customerChats.firstWhere((chat) => chat.id == chatId);
    } catch (_) {
      try {
        return adminChats.firstWhere((chat) => chat.id == chatId);
      } catch (_) {
        return null;
      }
    }
  }
}
