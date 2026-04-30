import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/app_routes.dart';
import 'package:event_maker/models/chat_model.dart';
import 'chat_view_controller.dart';
import 'chat_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatefulWidget {
  final bool isServiceProvider;

  const ChatView({super.key, required this.isServiceProvider});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late ChatViewController controller;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isFirstBuild = true;
  String? _lastChatDetailRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use Get.put to register controller, or Get.find if already registered
    if (Get.isRegistered<ChatViewController>()) {
      controller = Get.find<ChatViewController>();
    } else {
      controller = Get.put(ChatViewController());
    }
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController = TextEditingController();

    // Listen to search query changes to update the text field
    controller.searchQuery.listen((query) {
      _searchController.text = query;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: query.length),
      );
    });
  }

  void _onTabChanged() {
    // Only clear search when tab actually changes (not during animation)
    if (!_tabController.indexIsChanging) {
      controller.updateSearchQuery('');
      // For service provider, check if admin tab opened for first time
      if (widget.isServiceProvider && _tabController.index == 1) {
        _checkAndCreateAdminChat();
      }
    }
  }

  Future<void> _checkAndCreateAdminChat() async {
    final adminChats = controller.adminChats;
    if (adminChats.isEmpty && !controller.isLoading.value) {
      final chatRepo = ChatRepository();
      final adminChat = await chatRepo.createOrGetAdminChat();
      if (adminChat != null) {
        controller.adminChats.add(adminChat);
        final adminMember = adminChat.members.firstWhereOrNull(
          (m) => m.role == 'admin',
        );
        final displayName = adminMember?.fullName?.isNotEmpty == true
            ? adminMember!.fullName!
            : 'Event Link';
        final avatarUrl = adminMember?.avatar?.isNotEmpty == true
            ? ApiConstant.getFullMediaUrl(adminMember!.avatar)
            : 'assets/icons/icon.svg';
        _lastChatDetailRoute = '/chat/detail';
        await Get.toNamed(
          AppRoutes.chatDetail,
          arguments: {
            'id': adminChat.id,
            'name': displayName,
            'image': avatarUrl,
            'isAdmin': true,
          },
        );
        if (mounted) {
          controller.refreshChats();
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_lastChatDetailRoute == '/chat/detail') {
        controller.refreshChats();
      }
      _lastChatDetailRoute = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh chats on first build and when returning to this screen
    if (_isFirstBuild) {
      _isFirstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.refreshChats();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 24.w,
        automaticallyImplyLeading: false,
        leadingWidth: 40.w,
        title: Text(
          'chats'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: widget.isServiceProvider
          ? _buildServiceProviderView(controller)
          : _buildCustomerView(controller),
    );
  }

  Widget _buildServiceProviderView(ChatViewController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
              splashFactory: NoSplash.splashFactory,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.textPrimary,
              physics: const BouncingScrollPhysics(),
              dividerColor: Colors.transparent,
              tabs: [_buildTab('customer'.tr), _buildTab('admin'.tr)],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChatListContent(controller, true),
              _buildChatListContent(controller, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerView(ChatViewController controller) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Expanded(child: _buildChatListContent(controller, true)),
      ],
    );
  }

  Widget _buildChatListContent(
    ChatViewController controller,
    bool isCustomerTab,
  ) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final chats = isCustomerTab
          ? controller.filteredCustomerChats
          : controller.filteredAdminChats;
      final hasQuery = controller.searchQuery.value.isNotEmpty;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            _buildSearchBar(controller),
            SizedBox(height: 24.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshChats,
                color: AppColors.primary,
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  final chats = isCustomerTab
                      ? controller.filteredCustomerChats
                      : controller.filteredAdminChats;

                  if (isLoading) {
                    return Skeletonizer(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 20.h),
                        itemBuilder: (context, index) {
                          return _buildChatTileMock();
                        },
                      ),
                    );
                  }

                  if (chats.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        Center(
                          child: Text(
                            hasQuery
                                ? 'noResultsFound'.tr
                                : 'postVibeFirstChat'.tr,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: chats.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 20.h),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _buildChatTile(
                          chat,
                          isAdminChat: !isCustomerTab,
                          isServiceProvider: widget.isServiceProvider,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(ChatViewController controller) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'search'.tr,
          hintStyle: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => controller.updateSearchQuery(''),
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildChatTileMock() {
    return Row(
      children: [
        CircleAvatar(radius: 24.r, backgroundColor: Colors.grey[200]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120.w, height: 16.h, color: Colors.grey[200]),
              SizedBox(height: 6.h),
              Container(width: 200.w, height: 14.h, color: Colors.grey[200]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(
    ChatModel chat, {
    bool isAdminChat = false,
    bool isServiceProvider = false,
  }) {
    // For admin chats, find the admin member and use their full_name
    // For normal chats, use the other participant's full_name
    String displayName;
    String? avatarUrl;

    if (isAdminChat) {
      // Find admin member in the chat
      final adminMember = chat.members.firstWhereOrNull(
        (m) => m.role == 'admin',
      );
      displayName = adminMember?.fullName?.isNotEmpty == true
          ? adminMember!.fullName!
          : 'Event Link'; // Default admin name from API
      // Use admin member's avatar, or fallback to icon
      avatarUrl = adminMember?.avatar?.isNotEmpty == true
          ? ApiConstant.getFullMediaUrl(adminMember!.avatar)
          : 'assets/icons/icon.svg'; // Admin icon
    } else {
      // For normal chats, find the other participant
      // If service provider is viewing, show the customer
      // If customer is viewing, show the provider
      ChatMember? otherMember;

      if (chat.members.isNotEmpty) {
        // Determine which member to show based on who's viewing
        otherMember = chat.members.firstWhereOrNull(
          (m) =>
              isServiceProvider ? m.role == 'customer' : m.role != 'customer',
        );
        // Fallback to second member if no matching member found
        otherMember ??= chat.members.length > 1
            ? chat.members[1]
            : chat.members.first;
      }

      displayName = otherMember?.fullName?.isNotEmpty == true
          ? otherMember!.fullName!
          : otherMember?.email ?? 'Unknown';

      // Build full avatar URL using ApiConstant.getFullMediaUrl()
      avatarUrl = otherMember?.avatar?.isNotEmpty == true
          ? ApiConstant.getFullMediaUrl(otherMember!.avatar)
          : 'assets/icons/icon.svg';
    }

    return InkWell(
      onTap: () async {
        _lastChatDetailRoute = '/chat/detail';
        await Get.toNamed(
          AppRoutes.chatDetail,
          arguments: {
            'id': chat.id,
            'name': displayName,
            'image': avatarUrl,
            'isAdmin': isAdminChat,
          },
        );
        if (mounted) {
          controller.refreshChats();
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          // Use CircleAvatar for network images, SvgPicture for SVG icons
          avatarUrl?.startsWith('http') == true
              ? CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(avatarUrl!),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                )
              : CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: SvgPicture.asset(
                    avatarUrl ?? 'assets/icons/icon.svg',
                    width: 20.w,
                    height: 20.h,
                    // colorFilter: const ColorFilter.mode(
                    //   AppColors.primary,
                    //   BlendMode.srcIn,
                    // ),
                  ),
                ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // TODO: Add unread count badge if available from API
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  chat.lastMessage?.content ?? 'No messages yet',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
