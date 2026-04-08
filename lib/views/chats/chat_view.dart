import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/app_routes.dart';
import 'package:event_maker/models/chat_model.dart';
import 'chat_view_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatelessWidget {
  final bool isServiceProvider;

  const ChatView({super.key, required this.isServiceProvider});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatViewController());

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
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isServiceProvider
          ? _buildServiceProviderView(controller)
          : _buildCustomerView(controller),
    );
  }

  Widget _buildServiceProviderView(ChatViewController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
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
              children: [
                _buildChatListContent(controller, true),
                _buildChatListContent(controller, false),
              ],
            ),
          ),
        ],
      ),
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

      if (chats.isEmpty && !isLoading) {
        return Center(
          child: Text(
            'postVibeFirstChat'.tr,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            _buildSearchBar(controller),
            SizedBox(height: 24.h),
            Expanded(
              child: Skeletonizer(
                enabled: isLoading,
                child: ListView.separated(
                  itemCount: isLoading ? 4 : chats.length,
                  separatorBuilder: (context, index) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      return _buildChatTileMock();
                    }
                    final chat = chats[index];
                    return _buildChatTile(chat, isAdminChat: !isCustomerTab);
                  },
                ),
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

  Widget _buildChatTile(ChatModel chat, {bool isAdminChat = false}) {
    // Get display name for the chat
    final displayName = isAdminChat 
        ? (chat.name ?? 'Admin')
        : (chat.members.isNotEmpty ? chat.members.first.email : 'Unknown');
    
    // Get avatar from member or use default
    final avatarUrl = 'assets/images/person.jpg';

    return InkWell(
      onTap: () {
        Get.toNamed(
          AppRoutes.chatDetail,
          arguments: {
            'id': chat.id,
            'name': displayName,
            'image': avatarUrl,
            'isAdmin': isAdminChat,
          },
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: avatarUrl.startsWith('http')
                ? NetworkImage(avatarUrl)
                : AssetImage(avatarUrl) as ImageProvider,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                          fontWeight: FontWeight.w600,
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
