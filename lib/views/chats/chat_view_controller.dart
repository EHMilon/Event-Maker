import 'package:get/get.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/repository/chat_repository.dart';

/// Controller for the chat list view.
/// Uses [ChatRepository] for data fetching with backend-compatible patterns.
class ChatViewController extends GetxController {
  final ChatRepository _repository = const ChatRepository();

  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final hasError = false.obs;
  String? errorMessage;

  // Typed chat lists using proper models
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

  /// Loads both customer and admin chats from the repository.
  Future<void> loadChats() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = null;

    try {
      // Fetch customer chats
      final customerResponse = await _repository.fetchChats(isAdmin: false);
      customerChats.value = customerResponse.chats;
      filteredCustomerChats.value = customerResponse.chats;

      // Fetch admin chats
      final adminResponse = await _repository.fetchChats(isAdmin: true);
      adminChats.value = adminResponse.chats;
      filteredAdminChats.value = adminResponse.chats;
    } catch (e) {
      hasError.value = true;
      errorMessage = e.toString();
      // TODO: Handle error appropriately (show snackbar, log, etc.)
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes the chat lists (for pull-to-refresh).
  Future<void> refreshChats() async {
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

    filteredCustomerChats.value = customerChats
        .where(
          (chat) =>
              chat.participant.name.toLowerCase().contains(query) ||
              chat.lastMessage.content.toLowerCase().contains(query),
        )
        .toList();

    filteredAdminChats.value = adminChats
        .where(
          (chat) =>
              chat.participant.name.toLowerCase().contains(query) ||
              chat.lastMessage.content.toLowerCase().contains(query),
        )
        .toList();
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
