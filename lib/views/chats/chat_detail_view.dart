import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/chats/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Chat detail / conversation screen.
/// Shows messages between the current user and a selected chat contact.
class ChatDetailView extends StatelessWidget {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          // Messages container with gradient background per design
          Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Skeletonizer(
                    enabled: true,
                    child: _buildShimmerMessages(),
                  );
                }
                return _buildMessagesList(
                  controller,
                  isAdminView: controller.isAdminChat,
                );
              }),
            ),
          // Message input
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  /// AppBar with back arrow, profile picture and contact name.
  PreferredSizeWidget _buildAppBar(ChatDetailController controller) {
    final displayName = controller.isAdminChat
        ? '${controller.chatName} (${'admin'.tr})'
        : controller.chatName;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.w),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
      CircleAvatar(
        radius: 20.r,
        backgroundImage: controller.chatImage.startsWith('http')
            ? NetworkImage(controller.chatImage)
            : AssetImage(controller.chatImage) as ImageProvider,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              displayName,
              style: GoogleFonts.roboto(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Admin chat body with welcome message and recommended topics.
  Widget _buildAdminChatBody(ChatDetailController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          // Welcome header
          Text(
            'Hello !',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'adminChatWelcome'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 40.h),
          // Recommended Topics section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'recommendedTopics'.tr,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Topic cards
          ...controller.recommendedTopics.map(
            (topic) => _buildTopicCard(topic, controller),
          ),
        ],
      ),
    );
  }

  /// Recommended topic card widget.
  Widget _buildTopicCard(
    Map<String, dynamic> topic,
    ChatDetailController controller,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          // TODO: Send the topic text as a message
          controller.messageText.value = topic['text'] ?? '';
          controller.sendMessage();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text(topic['emoji'] ?? '💬', style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  topic['text'] ?? '',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Regular messages list for customer chats.
  Widget _buildMessagesList(
    ChatDetailController controller, {
    bool isAdminView = false,
  }) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 22.w,
        right: 22.w,
        top: 16.h,
        bottom: 16.h,
      ),
      itemCount: controller.messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(message, isAdminView: isAdminView);
      },
    );
  }

  /// Individual message bubble widget.
  Widget _buildMessageBubble(
    Map<String, dynamic> message, {
    bool isAdminView = false,
  }) {
    final isMe = message['isMe'] ?? false;
    final messageType = message['type'] as String? ?? 'text';
    final isAdminWelcome = isAdminView && !isMe && messageType == 'header';
    final isAdminSubtitle =
        isAdminView && !isMe && messageType == 'subtitle';

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isAdminWelcome
                ? Colors.transparent
                : isMe
                    ? Colors.white
                    : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 12.r : 0.r),
              topRight: Radius.circular(isMe ? 0.r : 12.r),
              bottomLeft: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
            ),
            border: isAdminWelcome
                ? null
                : Border.all(color: const Color(0xFFF2F2F2)),
            boxShadow: isAdminWelcome
                ? null
                : [
                    BoxShadow(
                      color: const Color.fromARGB(51, 70, 70, 70),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: isAdminWelcome
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['text'] ?? '',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'adminChatWelcome'.tr,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : Text(
                  message['text'] ?? '',
                  style: GoogleFonts.roboto(
                    color: isAdminSubtitle
                        ? AppColors.textSecondary
                        : const Color(0xFF5E5F60),
                    fontSize: 14.sp,
                    fontWeight: isAdminSubtitle
                        ? FontWeight.w500
                        : FontWeight.w400,
                    height: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  /// Shimmer placeholder for loading state.
  Widget _buildShimmerMessages() {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 22.w,
        right: 22.w,
        top: 16.h,
        bottom: 16.h,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 200.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 12.r : 0.r),
                  topRight: Radius.circular(isMe ? 0.r : 12.r),
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Message input field with send button at the bottom.
  Widget _buildMessageInput(ChatDetailController controller) {
    final textController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(color: AppColors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Color(0xFFEBEBEB)), // #EBEBEB
                ),
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: textController,
                  onChanged: controller.updateMessageText,
                  style: GoogleFonts.roboto(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message',
                    hintStyle: GoogleFonts.roboto(
                      color: Color(0xFF818181), // #818181
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Send button
            GestureDetector(
              onTap: () {
                controller.sendMessage();
                textController.clear();
              },
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFEBEBEB)), // #EBEBEB
                ),
                child: SvgPicture.asset(
                  'assets/icons/send.svg',
                  height: 40.h,
                  width: 40.w,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
