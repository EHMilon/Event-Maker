import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/core/routes/app_routes.dart';
import 'chat_view_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatelessWidget {
  final bool isServiceProvider;

  const ChatView({super.key, required this.isServiceProvider});

  @override
  Widget build(BuildContext context) {
    // We register the controller lazily here so it gets created when the tab is accessed
    final controller = Get.put(ChatViewController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 40.w,
        // leading: Builder(
        //   builder: (context) {
        //     final navigator = Navigator.of(context);
        //     if (navigator.canPop()) {
        //       return IconButton(
        //         icon: Icon(
        //           Icons.arrow_back,
        //           color: AppColors.textPrimary,
        //           size: 24.w,
        //         ),
        //         onPressed: () => navigator.pop(),
        //       );
        //     }
        //     return const SizedBox.shrink();
        //   },
        // ),
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
    // using DefaultTabController for custom tabs
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Container(
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textPrimary,
                physics: const BouncingScrollPhysics(),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
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
          ? controller.customerChats
          : controller.adminChats;

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

  Widget _buildChatTile(Map<String, dynamic> chat, {bool isAdminChat = false}) {
    return InkWell(
      onTap: () {
        // Navigate to chat detail screen with chat data
        Get.toNamed(
          AppRoutes.chatDetail,
          arguments: {
            'id': chat['id'],
            'name': chat['name'],
            'image': chat['image'] ?? 'assets/images/person.jpg',
            'isAdmin': isAdminChat,
          },
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: const AssetImage(
              'assets/images/person.jpg',
            ), // fallback
            // ignore: prefer_const_constructors
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['name'] ?? 'User Name',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  chat['lastMessage'] ?? '',
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
