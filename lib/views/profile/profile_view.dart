import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/widgets/permission_based_widget.dart';
import '../../shared/utils/user_preferences.dart';

/// Profile View with conditional UI based on user type.
///
/// This view demonstrates:
/// - Same base UI for both customer and service provider
/// - Different sections shown based on user type
/// - Edit button only visible to service providers
/// - Dynamic data from SharedPreferences (placeholder for backend)
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          // Logout button for all users
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await UserPreferences.clearUserData();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>?>(
        future: UserPreferences.getUserDetails(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Get user data or use defaults
          final userData = snapshot.data;
          final userName = userData?['name'] ?? 'Guest User';
          final userEmail = userData?['email'] ?? 'guest@example.com';
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                _buildProfileHeader(userName, userEmail),
                
                SizedBox(height: 24.h),
                
                // Personal Information (for all users)
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildInfoItem('Name', userName),
                    _buildInfoItem('Email', userEmail),
                    _buildInfoItem('Phone', '+1 234 567 8900'), // TODO: Get from backend
                    _buildInfoItem('Location', 'New York, USA'), // TODO: Get from backend
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Service Provider specific sections
                PermissionBasedWidget(
                  serviceProviderBuilder: () => _buildServiceProviderSection(),
                  customerBuilder: () => const SizedBox.shrink(),
                ),
                
                SizedBox(height: 24.h),
                
                // Conditional edit button - only for service providers
                PermissionBasedWidget(
                  serviceProviderBuilder: () => _buildEditButton(),
                  customerBuilder: () => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 40.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                // User type badge
                _buildUserTypeBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserTypeBadge() {
    return PermissionBasedWidget(
      serviceProviderBuilder: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'Service Provider',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.blue[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      customerBuilder: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'Customer',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.green[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label: ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceProviderSection() {
    return _buildSection(
      title: 'Service Information',
      children: [
        _buildInfoItem('Service Type', 'Photography'), // TODO: Get from backend
        _buildInfoItem('Experience', '5 years'), // TODO: Get from backend
        _buildInfoItem('Rating', '4.8 (120 reviews)'), // TODO: Get from backend
      ],
    );
  }
  
  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        Get.toNamed('/edit-profile');
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_outlined),
          SizedBox(width: 8.w),
          Text(
            'Edit Profile',
            style: TextStyle(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}