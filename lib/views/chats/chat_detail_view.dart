import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/chats/chat_detail_controller.dart';
import 'package:event_maker/views/chats/chat_view_controller.dart';
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
              return _buildMessagesList(controller);
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
    final displayName = controller.chatName;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.w),
        onPressed: () {
          // Refresh chat list before going back
          if (Get.isRegistered<ChatViewController>()) {
            Get.find<ChatViewController>().refreshChats();
          }
          Get.back();
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Use CircleAvatar for network images, SvgPicture for SVG icons
          controller.chatImage.startsWith('http')
              ? CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(controller.chatImage),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                )
              : CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: SvgPicture.asset(
                    controller.chatImage,
                    width: 18.w,
                    height: 18.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
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

  /// Messages list from API.
  Widget _buildMessagesList(ChatDetailController controller) {
    return Obx(() {
      final messages = controller.messages;

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No messages yet',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Start the conversation!',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(
          left: 22.w,
          right: 22.w,
          top: 16.h,
          bottom: 16.h,
        ),
        itemCount: messages.length,
        reverse: true,
        itemBuilder: (context, index) {
          final message = messages[index];
          // Check if sender is current user for WhatsApp-style alignment
          // sender.id is compared with currentUserId (both are String)
          final isMe =
              controller.currentUserId != null &&
              message.sender.id == controller.currentUserId;
          return _buildMessageBubble(
            isMe: isMe,
            content: message.content,
            createdAt: message.createdAt,
          );
        },
      );
    });
  }

  /// Individual message bubble widget.
  Widget _buildMessageBubble({
    required bool isMe,
    required String content,
    required DateTime createdAt,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isMe ? Colors.white : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 12.r : 0.r),
              topRight: Radius.circular(isMe ? 0.r : 12.r),
              bottomLeft: Radius.circular(12.r),
              bottomRight: Radius.circular(12.r),
            ),
            border: Border.all(color: const Color(0xFFF2F2F2)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(51, 70, 70, 70),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Text(
            content,
            style: GoogleFonts.roboto(
              color: const Color(0xFF5E5F60),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
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
      decoration: const BoxDecoration(color: AppColors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
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
                      color: const Color(0xFF818181),
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
            Obx(() {
              final isSending = controller.isSending.value;
              return GestureDetector(
                onTap: isSending
                    ? null
                    : () {
                        controller.sendMessage();
                        textController.clear();
                      },
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEBEBEB)),
                  ),
                  child: isSending
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: AppColors.primary,
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/icons/send.svg',
                          height: 40.h,
                          width: 40.w,
                          fit: BoxFit.none,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
